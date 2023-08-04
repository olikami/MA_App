from rest_framework import viewsets, mixins

from certificates.models import ApplicationUser, CertificateSigningRequest, Certificate
from certificates.serializers import (
    ApplicationUserSerializer,
    CertificateSigningRequestSerializer,
    CertificateSerializer,
)


class CreateRetrieveViewSet(
    mixins.CreateModelMixin,
    mixins.RetrieveModelMixin,
    viewsets.GenericViewSet,
):
    """
    A viewset the only allows to create and retrieve the model
    """

    pass


class ApplicationUserViewSet(CreateRetrieveViewSet):
    serializer_class = ApplicationUserSerializer
    queryset = ApplicationUser.objects.all()


class CertificateSigningRequestViewSet(CreateRetrieveViewSet):
    serializer_class = CertificateSigningRequestSerializer
    queryset = CertificateSigningRequest.objects.all()


class CertificateViewSet(CreateRetrieveViewSet):
    serializer_class = CertificateSerializer
    queryset = Certificate.objects.all()
