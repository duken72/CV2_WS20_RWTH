import argparse
import scipy.io
from glob import glob
import cv2
import numpy as np
import plot_utils as utils
import pretty_print
from tracker import Tracker


if __name__ == "__main__":
    parser = argparse.ArgumentParser()

    parser.add_argument("--input_path", type=str, default="../../data/soccer",
                        help="root directory of surveillance sequence")
    parser.add_argument("--gating_area", type=float, default=50,
                       help="size of gating area")
    parser.add_argument('--use_hungarian', dest='use_hungarian', action='store_true')
    parser.set_defaults(use_hungarian=False)
    parser.add_argument('--use_kalman', dest='use_kalman', action='store_true')
    parser.set_defaults(use_kalman=False)
    parser.add_argument('--use_mahalanobis', dest='use_mahalanobis', action='store_true')
    parser.set_defaults(use_mahalanobis=False)
    parser.add_argument("--weight", type=float, default=1,
                        help="weighting between spatial distance and color histograms")

    args = parser.parse_args()
    pretty_print.pretty_print_arguments(args)

    image_path = f"{args.input_path}/frames/"
    detections_path = f"{args.input_path}/soccerboxes.mat"

    mat = scipy.io.loadmat(detections_path)
    detections = mat['allboxes']

    file_paths = sorted(glob(f"{image_path}/*.jpg"))

    tracker = Tracker(args.gating_area, args.use_hungarian, args.use_kalman, args.use_mahalanobis, args.weight)

    for i, file_path in enumerate(file_paths):
        img = cv2.imread(file_path)
        img_tracks = img.copy()

        utils.plot_gt(img, detections, i+1, boxes=True)

        curr_dets = detections[detections[:, 0] == i + 1, 2:]

        observations = list()
        # prepare list of observations with keys position and histogram
        for det in curr_dets:
            # compute 8x8x8 color histogram of cropped detection
            tmp = img[int(det[1] - det[3] / 2):int(det[1] + det[3] / 2), int(det[0] - det[2] / 2):int(det[0] + det[2] / 2), :]
            #                   crop   color channels   bin resol  ranges for each bin  todo
            hist = cv2.calcHist([tmp], [0, 1, 2], None, [8, 8, 8], [0, 256, 0, 256, 0, 256], accumulate=False)

            observations.append({
                'pos': det[:2],
                'hist': hist
            })

        tracks, debug_info = tracker.update(observations)

        if args.use_kalman:
            # plot white predicted states
            utils.plot_detections(img, np.array(debug_info['predicted_positions']), (255, 255, 255))

        utils.plot_tracks(img_tracks, tracks)
        utils.plot_results(img, img_tracks)
