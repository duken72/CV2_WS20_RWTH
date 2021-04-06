"""
Tracker Class supporting validation volumes, hungarian matching, kalman filters with mahalanobis distance and
simple support of color histograms
author: Jonas Schult schult@vision.rwth-aachen.de
adapted from: https://www.pyimagesearch.com/2018/07/23/simple-object-tracking-with-opencv/
"""

import copy
from collections import OrderedDict
from typing import List, Dict

import cv2
import numpy as np
import scipy.optimize
from filterpy.kalman import KalmanFilter
from scipy.spatial import distance as dist
from scipy.stats import chi2


class Tracker:
    def __init__(self, gating_area: int = 50, use_hungarian: bool = False, use_kalman: bool = True,
                 use_mahalanobis: bool = True, weight: float = 1):
        assert gating_area >= 0, "gating areas need to be positive"
        assert 0 <= weight <= 1, "weight needs to be in range [0,1]"

        self.next_object_id = 0
        self.object_states = OrderedDict()
        self.tracks = OrderedDict()
        self.gating_area = gating_area
        self.weight = weight
        self.use_hungarian = use_hungarian
        self.use_kalman = use_kalman
        self.use_mahalanobis = use_mahalanobis

        if self.use_kalman:
            self.filters = OrderedDict()

    @staticmethod
    def _get_kalman_filter(position_state):
        # constant velocity model
        # state vector (pos_x, pos_y, v_x, v_y)
        # measurement input (pos_x, pos_y)
        kalman_filter = KalmanFilter(dim_x=4, dim_z=2)
        # initial state vector (position of detection, 0 velocity)
        kalman_filter.x = np.array([[position_state[0]], [position_state[1]], [0.], [0.]])
        # state transition matrix (in slides: D) dynamics model
        kalman_filter.F = np.array([[1, 0,  1,  0],
                                    [0, 1,  0,  1],
                                    [0, 0,  1,  0],
                                    [0, 0,  0,  1]])
        # measurement model (in slides: M)
        kalman_filter.H = np.array([[1, 0, 0, 0],
                                    [0, 1, 0, 0]])

        # current state covariance matrix (gets updated after update() and predict())
        kalman_filter.P *= 1.77
        # Measurement noise matrix
        kalman_filter.R *= 0.11

        return kalman_filter

    def _kalman_predict(self):
        object_states = []
        # predict step
        for object_id, kalman_filter in self.filters.items():
            # predict next state of each track
            kalman_filter.predict()
            object_state = kalman_filter.x_prior[:2, 0]  # extract only position (not velocity)
            object_states.append(object_state)
        return object_states

    def register(self, object_state: Dict[str, np.ndarray]):
        # when registering an object, we use the next available object ID to store the track
        self.object_states[self.next_object_id] = object_state
        self.tracks[self.next_object_id] = [object_state]

        if self.use_kalman:
            self.filters[self.next_object_id] = self._get_kalman_filter(object_state['pos'])

        self.next_object_id += 1

    def deregister(self, object_id: int):
        # to deregister an object ID we delete the object ID from
        # both of our respective dictionaries
        del self.object_states[object_id]
        del self.tracks[object_id]

        if self.use_kalman:
            del self.filters[object_id]

    def update(self, observations: List[Dict[str, np.ndarray]]):
        pos_states = []
        if len(observations) == 0:
            # no observations in current frame -> delete all tracks
            for object_id in list(self.object_states.keys()):
                self.deregister(object_id)
            return self.tracks

        if len(self.object_states) == 0:
            # there are no current tracks -> start new ones
            for observation in observations:
                self.register(observation)
        else:
            # grab the set of object IDs and corresponding centroids
            object_ids = list(self.object_states.keys())

            # deepcopy since in case of kalman filter, we want to put predicted positions in data structure
            object_states = list(copy.deepcopy(self.object_states).values())

            if self.use_kalman:
                pos_states = self._kalman_predict()
                for i, object_state in enumerate(object_states):
                    object_state['pos'] = pos_states[i]

            # collect position information
            position_states = np.array([state['pos'] for state in object_states])
            observed_positions = np.array([obs['pos'] for obs in observations])

            position_distances = list()

            if self.use_mahalanobis:
                for object_id, kalman_filter in self.filters.items():
                    # mahalanobis distance under state covariance matrix --> chi^2 distributed for thresholding
                    distance = dist.cdist(kalman_filter.x_prior[:2, 0][np.newaxis, ...],
                                          observed_positions, 'mahalanobis',
                                          VI=np.linalg.inv(kalman_filter.P_prior[:2, :2]))
                    position_distances.append(chi2.cdf(distance, 2))

                position_distances = np.concatenate(position_distances, axis=0)
            else:
                # find nearest neighbors of all current tracks
                # row: tracked object; column: new observation
                position_distances = dist.cdist(position_states, observed_positions)

            hist_distances = np.zeros(position_distances.shape)

            if 'hist' in observations[0]:
                hist_states = np.array([state['hist'] for state in object_states])
                hist_obs = np.array([obs['hist'] for obs in observations])

                for i in range(len(hist_states)):
                    for j in range(len(hist_obs)):
                        hist_distances[i, j] = 1-cv2.compareHist(hist_states[i], hist_obs[j], cv2.HISTCMP_CORREL)

            # combine different metrics (for ETH we only need positions)
            # soccer dataset also provides us with bounding boxes (e.g. we can calculate color histograms of objects)
            cost_matrix = self.weight * position_distances + (1-self.weight) * hist_distances

            # keep track of used tracks and new observations, because we might need to start or delete tracks
            used_tracks = set()
            used_observations = set()

            if not self.use_hungarian:
                # nearest neighbor matching within validation volume
                while cost_matrix.min() < self.gating_area:
                    # if we have a nearest neighbor within the validation volume, we assign it to the track
                    # we delete the track and observation from the distance matrix and search for the next best match
                    # note: this is not an efficient implementation!
                    # Refer to "A Review of Statistical Data Association Techniques for Motion Correspondence"
                    # by Cox, 1993 for more detail

                    # row: tracked object; column: new observation
                    # note: np.argmin() returns the index of a flattened matrix --> unravel it
                    row_id, observation_id = np.unravel_index(cost_matrix.argmin(), cost_matrix.shape)

                    object_id = object_ids[row_id]  # we need to map row ids to tracked object ids
                    self.object_states[object_id] = observations[observation_id]
                    self.tracks[object_id].append(observations[observation_id])

                    if self.use_kalman:
                        self.filters[object_id].update(observations[observation_id]['pos'])

                    # set row and column to infinity -> we do not consider them anymore
                    # this is faster / more elegant than deleting rows/columns since this changes the indexing!
                    cost_matrix[row_id, :] = np.inf
                    cost_matrix[:, observation_id] = np.inf

                    # book keeping --> we might need to start or delete tracks
                    used_tracks.add(object_id)
                    used_observations.add(observation_id)
            else:
                # filter out observation not in validation volume
                cost_matrix[cost_matrix > self.gating_area] = 1e10  # high value to make assignment unattractive
                object_idx, observation_idx = scipy.optimize.linear_sum_assignment(cost_matrix)  # Hungarian Algorithm

                for assignment_id in range(len(object_idx)):
                    object_id = object_ids[object_idx[assignment_id]]
                    observation_id = observation_idx[assignment_id]

                    # check if assignment is in validation volume
                    if cost_matrix[object_idx[assignment_id], observation_id] < self.gating_area:
                        self.object_states[object_id] = observations[observation_id]
                        self.tracks[object_id].append(observations[observation_id])

                        if self.use_kalman:
                            # update kalman filters with *assigned* current observations
                            self.filters[object_id].update(observations[observation_id]['pos'])

                        # book keeping --> we might need to start or delete tracks
                        used_tracks.add(object_id)
                        used_observations.add(observation_id)

            # find object ids which have been not updated
            unused_tracks = set(self.object_states.keys()).difference(used_tracks)
            unused_observations = set(range(0, cost_matrix.shape[1])).difference(used_observations)

            # end tracks which have not been updated
            for object_id in unused_tracks:
                self.deregister(object_id)

            # start new tracks for observations which haven't been used for updating tracks
            for observation_id in unused_observations:
                self.register(observations[observation_id])

        # return the set of trackable objects
        return self.tracks, {'predicted_positions': pos_states}
