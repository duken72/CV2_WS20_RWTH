import scipy.io
import argparse
from glob import glob
import cv2
import numpy as np
from tracker import Tracker
import pretty_print
import plot_utils as utils

if __name__ == "__main__":
    parser = argparse.ArgumentParser()

    parser.add_argument("--input_path", type=str, default="../../data/eth",
                        help="root directory of surveillance sequence")
    parser.add_argument("--gating_area", type=float, default=50,
                       help="size of gating area")
    parser.add_argument('--annotations', dest='annotations', action='store_true')
    parser.add_argument('--observations', dest='annotations', action='store_false')
    parser.set_defaults(annotations=True)
    parser.add_argument('--use_hungarian', dest='use_hungarian', action='store_true')
    parser.set_defaults(use_hungarian=False)
    parser.add_argument('--use_kalman', dest='use_kalman', action='store_true')
    parser.set_defaults(use_kalman=False)
    parser.add_argument('--use_mahalanobis', dest='use_mahalanobis', action='store_true')
    parser.set_defaults(use_mahalanobis=False)

    args = parser.parse_args()
    pretty_print.pretty_print_arguments(args)

    image_path = f"{args.input_path}/frames/"
    detections_path = f"{args.input_path}/{'annotations.mat' if args.annotations else 'observations.mat'}"

    mat = scipy.io.loadmat(detections_path)
    detections = mat['annotations'] if args.annotations else mat['observations']

    file_paths = sorted(glob(f"{image_path}/*.png"))

    tracker = Tracker(args.gating_area, args.use_hungarian, args.use_kalman, args.use_mahalanobis)

    for i, file_path in enumerate(file_paths):
        img = cv2.imread(file_path)
        img_tracks = img.copy()

        if i > 0:
            # previous measurement in red; indexing starts with 1
            utils.plot_detections(img, detections[detections[:, 0] == i, 1:], (0, 0, 255))

        # current measurement in blue
        utils.plot_detections(img, detections[detections[:, 0] == i + 1, 1:], (255, 255, 0))

        tracks, debug_info = tracker.update([{'pos': pos} for pos in detections[detections[:, 0] == i+1, 1:]])

        if args.use_kalman:
            # plot white predicted states
            utils.plot_detections(img, np.array(debug_info['predicted_positions']), (255, 255, 255))

        utils.plot_tracks(img_tracks, tracks, num_colors=15)
        utils.plot_results(img, img_tracks)
