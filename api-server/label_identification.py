import cv2
import numpy as np
import pytesseract
from pyzbar.pyzbar import decode
import os
from datetime import datetime

def displayImage(image):
    name_windown = 'image'
    width = int(image.shape[1] * 100 / 100)
    height = int(image.shape[0] * 100 / 100)
    cv2.namedWindow(name_windown, cv2.WINDOW_NORMAL)
    cv2.resizeWindow(name_windown, width, height)
    cv2.imshow(name_windown, image)
    cv2.waitKey(0)
    cv2.destroyAllWindows

def saveImage(image):
    current_time = datetime.now().strftime("%Y%m%d%H%M%S")
    cv2.imwrite(f"./images/img_{current_time}.jpeg", image)

def preprocessing(source, percent=10, kernel=(5,5)):
    
    try:
        # Calcula as novas dimensões da imagem
        width = int(source.shape[1] * percent / 100)
        height = int(source.shape[0] * percent / 100)

        # Redimensiona a imagem
        source = cv2.resize(source, (width, height), interpolation = cv2.INTER_AREA)

        # Transforma a imagem para escala de cinza
        #source = cv2.cvtColor(source, cv2.COLOR_BGR2GRAY)
        #displayImage(source)

        # Aplica um filtro gaussiano
        source = cv2.GaussianBlur(source, kernel, 0)
        #displayImage(source)

        # Aplica threshold
        _, thresh = cv2.threshold(source,0,255,cv2.THRESH_BINARY+cv2.THRESH_OTSU)
        #displayImage(thresh)
    
        return thresh
    
    except Exception as error:
        print('Erro na função preprocessing!')
        print(f'Erro: {error}')

def labelIdentification(source):
    
    image = preprocessing(source, percent=100, kernel=(5,5))

    # Encontra contornos na imagem
    contours, _ = cv2.findContours(image, cv2.RETR_TREE, cv2.CHAIN_APPROX_NONE)
    draw = np.copy(source)
    cv2.drawContours(draw, contours, -1, (0, 255, 0), 2)
    #displayImage(draw)

    # Razão da altura e largura da etiqueta
    aspect_ratio_label = 4.6/1.8

    img_copy = np.copy(source)
    roi_list = []

    for c in contours:
        # Perímetro
        epsilon = cv2.arcLength(c, True)

        if epsilon > 100:
            # Aproximando o perímetro
            approx = cv2.approxPolyDP(c, 0.03 * epsilon, True)

            x,y,w,h = cv2.boundingRect(c)

            area = int(w) * int(h)
            #print(area)

            if area > 10000 and area < 250000:
                aspect_ratio = w/h

                if aspect_ratio >= (aspect_ratio_label - 0.1*aspect_ratio_label) and aspect_ratio <= (aspect_ratio_label + 0.1*aspect_ratio_label):
                    cv2.rectangle(img_copy,(x,y),(x+w,y+h),(0,255,0),2)
                    #saveImage(img_copy)
                    roi_list.append(c)

    print(f'Placas detectadas: {len(roi_list)}')

    if len(roi_list) == 1:
        for item in roi_list:
            x,y,w,h = cv2.boundingRect(item)
            source_roi = source[y:y+h,x:x+w]
            thresh_roi = image[y:y+h,x:x+w]

        #saveImage(source_roi)
        #saveImage(thresh_roi)

        return source_roi, thresh_roi
    
def OCR(source):
    
    source_roi, thresh_roi = labelIdentification(source)
    kernel = np.ones((3,3), np.uint8)
    thresh_roi = cv2.morphologyEx(thresh_roi, cv2.MORPH_CLOSE, kernel)
    #saveImage(thresh_roi)


    str_barcode = ''
    barcode = decode(thresh_roi)
    
    if len(barcode) != 0:
        x, y, w, h = barcode[0].rect
        draw_bar = np.copy(source_roi)
        cv2.rectangle(draw_bar,(x,y),(x+w,y+h),(0,0,255), 4)
        #displayImage(draw_bar)

        for code in barcode:
            str_barcode = code.data.decode('utf-8')
            print('Código de barra: ', str_barcode)

        propo = 100
        xp = int(propo / (source_roi.shape[1]) * 100)

        adm_unity = thresh_roi[y+xp:,xp:x-xp]
        #displayImage(adm_unity)
        id_barcode = thresh_roi[:,x-xp:]
        #displayImage(id_barcode)
        
        config_char = r'-c tessedit_char_whitelist=AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz --psm 6 --oem 1'
        config_num = r'-c tessedit_char_whitelist=0123456789 --psm 6 --oem 1'

        chars = pytesseract.image_to_string(adm_unity, lang='por', config=config_char)
        numbers = pytesseract.image_to_string(id_barcode, lang='eng', config=config_num)

        return chars, numbers
    
    else:
        print('Código de barra não reconhecido.')
    
    # except Exception as error:
    #     print('Erro na função OCR!')
    #     print(f'Erro: {error}')
    #     return 0, 0

if __name__ == '__main__':
    # dir_path = '/home/nodyer/Área de Trabalho/TG Nodyer/TAG fotos'

    # files = os.listdir(dir_path)
    # images_list = []

    # for file in files:
    #     img_path = os.path.join(dir_path, file)
    #     print(img_path)
    #     source = cv2.imread(img_path)
    #     images_list.append(source)

    # scr = images_list[8]
    scr = cv2.imread('/home/nodyer/Área de Trabalho/IT-Asset-Manager-App/api-server/images/img_20231215164227.jpeg')
    displayImage(scr)

    chars, numbers = OCR(scr)
    print("Unidade administrativa: ", chars)
    print("ID do ativo: ", numbers)