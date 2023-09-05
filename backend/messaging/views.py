from rest_framework import viewsets, mixins
from .models import Location, Message, OfficialMessage
from .serializers import (
    LocationSerializer,
    MessageSerializer,
    OfficialMessageSerializer,
)


class LocationViewSet(viewsets.ReadOnlyModelViewSet):
    queryset = Location.objects.order_by("postcode")
    serializer_class = LocationSerializer


class MessageViewSet(
    mixins.ListModelMixin,
    mixins.RetrieveModelMixin,
    mixins.CreateModelMixin,
    viewsets.GenericViewSet,
):
    queryset = Message.objects.all()
    serializer_class = MessageSerializer


class OfficialMessageViewSet(
    mixins.ListModelMixin,
    mixins.RetrieveModelMixin,
    mixins.CreateModelMixin,
    viewsets.GenericViewSet,
):
    queryset = OfficialMessage.objects.all()
    serializer_class = OfficialMessageSerializer
