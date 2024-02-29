import cv2
import numpy as np
import pytesseract
from pyzbar.pyzbar import decode
from datetime import datetime

class LabelIdentification:
    def displayImage(self, image):
        name_windown = 'image'
        width = int(image.shape[1] * 100 / 100)
        height = int(image.shape[0] * 100 / 100)
        cv2.namedWindow(name_windown, cv2.WINDOW_NORMAL)
        cv2.resizeWindow(name_windown, width, height)
        cv2.imshow(name_windown, image)
        cv2.waitKey(0)
        cv2.destroyAllWindows()

    def saveImage(self, image):
        current_time = datetime.now().strftime("%Y%m%d%H%M%S")
        cv2.imwrite(f"./images/img_{current_time}.jpeg", image)

    def preprocessing(self, source, percent=10, kernel=(5,5)):
        try:
            width = int(source.shape[1] * percent / 100)
            height = int(source.shape[0] * percent / 100)
            source = cv2.resize(source, (width, height), interpolation = cv2.INTER_AREA)
            source = cv2.GaussianBlur(source, kernel, 0)
            _, thresh = cv2.threshold(source, 0, 255, cv2.THRESH_BINARY+cv2.THRESH_OTSU)
            return thresh
        except Exception as error:
            print('Erro na função preprocessing!')
            print(f'Erro: {error}')

    def labelIdentification(self, source):
        image = self.preprocessing(source, percent=100, kernel=(5,5))
        contours, _ = cv2.findContours(image, cv2.RETR_TREE, cv2.CHAIN_APPROX_NONE)
        draw = np.copy(source)
        cv2.drawContours(draw, contours, -1, (0, 255, 0), 2)
        aspect_ratio_label = 4.6/1.8
        img_copy = np.copy(source)
        roi_list = []

        for c in contours:
            epsilon = cv2.arcLength(c, True)
            if epsilon > 100:
                approx = cv2.approxPolyDP(c, 0.03 * epsilon, True)
                if len(approx) == 4:
                    x,y,w,h = cv2.boundingRect(c)
                    area = int(w) * int(h)
                    if area > 10000 and area < 250000:
                        aspect_ratio = w/h
                        if aspect_ratio >= (aspect_ratio_label - 0.1*aspect_ratio_label) and aspect_ratio <= (aspect_ratio_label + 0.1*aspect_ratio_label):
                            cv2.rectangle(img_copy,(x,y),(x+w,y+h),(0,255,0),2)
                            roi_list.append(c)

        print(f'Placas detectadas: {len(roi_list)}')

        if len(roi_list) == 1:
            for item in roi_list:
                x,y,w,h = cv2.boundingRect(item)
                source_roi = source[y:y+h,x:x+w]
                thresh_roi = image[y:y+h,x:x+w]
            return source_roi, thresh_roi

    def OCR(self, source):
        source_roi, thresh_roi = self.labelIdentification(source)
        kernel = np.ones((3,3), np.uint8)
        thresh_roi = cv2.morphologyEx(thresh_roi, cv2.MORPH_CLOSE, kernel)
        str_barcode = ''
        barcode = decode(thresh_roi)
        
        if len(barcode) != 0:
            x, y, w, h = barcode[0].rect
            draw_bar = np.copy(source_roi)
            cv2.rectangle(draw_bar,(x,y),(x+w,y+h),(0,0,255), 4)
            for code in barcode:
                str_barcode = code.data.decode('utf-8')
                print('Código de barra: ', str_barcode)
            propo = 100
            xp = int(propo / (source_roi.shape[1]) * 100)
            adm_unity = thresh_roi[y+xp:,xp:x-xp]
            id_barcode = thresh_roi[:,x-xp:]
            config_char = r'-c tessedit_char_whitelist=AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz --psm 6 --oem 1'
            config_num = r'-c tessedit_char_whitelist=0123456789 --psm 6 --oem 1'
            chars = pytesseract.image_to_string(adm_unity, lang='por', config=config_char)
            numbers = pytesseract.image_to_string(id_barcode, lang='eng', config=config_num)
            return chars, numbers
        else:
            print('Código de barra não reconhecido.')

if __name__ == '__main__':
    label_iden = LabelIdentification()
    scr = cv2.imread('/home/nodyer/Área de Trabalho/IT-Asset-Manager-App/api-server/images/img_20231215164227.jpeg')
    label_iden.displayImage(scr)
    chars, numbers = label_iden.OCR(scr)
    print("Unidade administrativa: ", chars)
    print("ID do ativo: ", numbers)
