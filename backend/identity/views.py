from rest_framework import viewsets, mixins

from identity.models import (
    ApplicationUser,
    CertificateSigningRequest,
    EndUserCertificate,
)
from identity.serializers import (
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
    queryset = EndUserCertificate.objects.all()
