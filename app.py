from flask import Flask,request,render_template,url_for,jsonify
from tensorflow.keras.models import load_model
from PIL import Image
import numpy as np 

app=Flask(__name__)

def preprocessing(image):
    image=Image.open(image)
    image=image.resize((256,256))
    image_arr=np.array(image.convert('RGB'))
    image_arr.shape=(1,256,256,3)
    return image_arr

classes=['Pepper Leaf Bacterial Spot', 'Pepper Leaf healthy']
model=load_model("model/3.keras")

@app.route('/')
def index():
    return render_template('index.html',appName="predict pepper dieses")

@app.route('/predictApi',methods=['POST'])
def api():
    try:
        if 'fileup' not in request.files:
            return "please try again"
        image=request.files.get('fileup')
        image_arr=preprocessing(image)
        result=model.predict(image_arr)
        ind=np.argmax(result)
        prediction=classes[ind]
        return jsonify({'prediction':prediction})
    except:
        return jsonify({'e'})

@app.route('/predict',methods=['GET','POST'])
def predict():
    print('run code')
    if request.method=='POST':
        print("image loading")
        image=request.files['fileup']
        print('image loaded')
        result=model.predict(image_arr)
        print("predicted")
        ind=np.argmax(result)
        prediction=classes[ind]
        
        print(prediction)
        
        return render_template('index.html',prediction=prediction,image='',appName='')
    else:
        return render_template('index.html',appName='')



if __name__=='__main__':
    app.run(host='192.168.43.122', port=5000, debug=True)      