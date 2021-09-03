import numpy as np
import cv2 as cv
import flask
from yolo import Yolo
from ocr import OCR

# The flask app for serving predictions
app = flask.Flask(__name__)


@app.route('/ping', methods=['GET'])
def ping():
    status = 200
    return flask.Response(response='test prediction ok', status=status, mimetype='application/json')


@app.route('/invocations', methods=['POST'])
def prediction():
    yolo = Yolo(img_width=1056, img_height=576,
                confidence_threshold=0.6, non_max_supress_theshold=0.4,
                classes_filename='config/classes.names',
                model_architecture_filename="config/yolov3_license_plates.cfg",
                model_weights_filename="config/yolov3_license_plates_last.weights",
                output_image=True)

    ocr = OCR(model_filename="config/attention_ocr_model.pth", use_cuda=False)

    img_bytes = flask.request.get_data()

    if img_bytes is not None:
        nparr = np.frombuffer(img_bytes, np.uint8)

        inputImage = cv.imdecode(nparr, cv.IMREAD_COLOR)

        roi_imgs = yolo.detect(inputImage, draw_bounding_box=False)

        index = 0
        api_output = []
        for roi_img in roi_imgs:
            box = [yolo.bounding_boxes[index][0], yolo.bounding_boxes[index][1], yolo.bounding_boxes[index][2],
                   yolo.bounding_boxes[index][3]]
            score = yolo.confidences[index]
            class_id = yolo.class_ids[index]

            pred = ocr.predict(roi_img)
            output = {'bounding_box': box, 'bb_confidence': score, 'ocr_pred': pred}
            api_output.append(output)
            index += 1
        print('prediction output::', api_output)
    return flask.Response(response=api_output, status=200, mimetype='application/json')