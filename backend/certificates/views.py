from rest_framework import viewsets

from certificates.models import ApplicationUser
from certificates.serializers import ApplicationUserSerializer


class ApplicationUserViewSet(viewsets.ModelViewSet):
    """
    A viewset for viewing and editing user instances.
    """

    serializer_class = ApplicationUserSerializer
    queryset = ApplicationUser.objects.all()
