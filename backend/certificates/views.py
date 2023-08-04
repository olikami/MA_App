from rest_framework import viewsets, mixins

from certificates.models import ApplicationUser, CertificateSigningRequest, Certificate
from certificates.serializers import (
    ApplicationUserSerializer,
    CertificateSigningRequestSerializer,
    CertificateSerializer,
)


class ApplicationUserViewSet(viewsets.ModelViewSet):
    """
    A viewset for viewing and editing user instances.
    """

    serializer_class = ApplicationUserSerializer
    queryset = ApplicationUser.objects.all()


class CertificateSigningRequestViewSet(viewsets.ModelViewSet):
    serializer_class = CertificateSigningRequestSerializer
    queryset = CertificateSigningRequest.objects.all()


class CertificateViewSet(viewsets.ModelViewSet):
    serializer_class = CertificateSerializer
    queryset = Certificate.objects.all()
