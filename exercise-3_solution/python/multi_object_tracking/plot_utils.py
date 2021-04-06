import numpy as np
import cv2
import random
import colorsys
from typing import List, Tuple, Dict
import functools


@functools.lru_cache(5)
def get_evenly_distributed_colors(count: int) -> List[Tuple[np.uint8, np.uint8, np.uint8]]:
    # lru cache caches color tuples
    HSV_tuples = [(x/count, 1.0, 1.0) for x in range(count)]
    random.shuffle(HSV_tuples)
    return list(map(lambda x: (np.array(colorsys.hsv_to_rgb(*x))*255).astype(np.uint8), HSV_tuples))


def plot_detections(img: np.ndarray, detections: np.ndarray, color: Tuple[int, int, int]) -> None:
    for pos in detections:
        cv2.circle(img, (int(pos[0]), int(pos[1])), 4, color, -1)


def plot_box(img: np.ndarray, detection: np.ndarray, color: Tuple[int, int, int]) -> None:
    # (center_x, center_y, width, height)
    color = tuple(color)
    color = (int(color[0]), int(color[1]), int(color[2]))

    cv2.circle(img, (int(detection[0]), int(detection[1])), 4, color, -1)
    cv2.rectangle(img,
                  (int(detection[0]-detection[2]/2), int(detection[1]-detection[3]/2)),
                  (int(detection[0]+detection[2]/2), int(detection[1]+detection[3]/2)), color, 2)


def plot_gt(img: np.ndarray, detections: np.ndarray,
            frame_number: int, boxes: bool = False, window_size: int = 60, num_colors: int = 10) -> None:
    colors = get_evenly_distributed_colors(num_colors)
    for detection_in_frame in detections[detections[:, 0] == frame_number]:
        color = tuple(colors[int(detection_in_frame[1]) % num_colors])
        color = (int(color[0]), int(color[1]), int(color[2]))

        if boxes:
            prev_dets = detections[detections[:, 1] == detection_in_frame[1]]
            prev_dets = prev_dets[(frame_number - window_size <= prev_dets[:, 0]) &
                                  (prev_dets[:, 0] <= frame_number)]

            for prev_det_id in range(1, len(prev_dets)):
                cv2.line(img, (int(prev_dets[prev_det_id-1][2]), int(prev_dets[prev_det_id-1][3])),
                         (int(prev_dets[prev_det_id][2]), int(prev_dets[prev_det_id][3])), color, 2)

            plot_box(img, detection_in_frame[2:], color)
        else:
            cv2.circle(img, (int(detection_in_frame[1]), int(detection_in_frame[1])), 4, color, -1)


def plot_tracks(img: np.ndarray, tracks: Dict[int, List[Dict[str, np.ndarray]]], num_colors: int = 10) -> None:
    colors = get_evenly_distributed_colors(num_colors)
    for track_id, states in tracks.items():
        # TODO alpha blending not straightforward in openCV
        color = tuple(colors[track_id % num_colors])
        color = (int(color[0]), int(color[1]), int(color[2]))
        for state_id in range(1, len(states)):
            cv2.line(img, (int(states[state_id - 1]['pos'][0]), int(states[state_id - 1]['pos'][1])),
                     (int(states[state_id]['pos'][0]), int(states[state_id]['pos'][1])), color, 2)


def plot_results(img_data: np.ndarray, img_result: np.ndarray) -> None:
    img_show = np.concatenate((img_data, 255 * np.ones((img_data.shape[0], 50, 3), dtype=np.uint8), img_result), axis=1)
    cv2.namedWindow("window", cv2.WND_PROP_FULLSCREEN)
    cv2.setWindowProperty("window", cv2.WND_PROP_FULLSCREEN, cv2.WINDOW_FULLSCREEN)
    cv2.imshow("window", img_show)
    cv2.waitKey(0)
