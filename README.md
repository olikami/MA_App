# MA_App

This application persists of two parts, the mobile application (in folder `app`) and the backend (in folder `backend`). 

## Backend

The backend application is a [DRF](https://www.django-rest-framework.org/) application. The application is started as follows:

1. Created venv
```
python -m venv venv
```
2. Activate virtual environment
```
source venv/bin/activate
```
3. Install `pip-tools`
```
pip install pip-tools
```
4. Sync needed packages
```
pip-sync
```
5. Start python server
```
python manage.py runserver
```

## Applicaiton

To use the application `XCode` is needed. A valid Apple Developer license may be needed.
1. Open app in XCode
2. Install requireed packages through [SPM](https://www.swift.org/package-manager/)
3. Compile applicaiton for simulator or other traget
4. Run application
