from django.urls import path, include
from rest_framework import routers

from certificates.views import ApplicationUserViewSet

router = routers.DefaultRouter()
router.register(r"application_user", ApplicationUserViewSet)


urlpatterns = [
    path("", include(router.urls)),
]
