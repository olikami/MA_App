from django.urls import path, include
from rest_framework import routers

from identity.views import (
    ApplicationUserViewSet,
    CertificateSigningRequestViewSet,
    CertificateViewSet,
)

router = routers.DefaultRouter()
router.register(r"application_user", ApplicationUserViewSet)
router.register(r"csr", CertificateSigningRequestViewSet)
router.register(r"certificate", CertificateViewSet)


urlpatterns = [
    path("", include(router.urls)),
]
