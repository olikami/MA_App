from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import LocationViewSet, MessageViewSet, OfficialMessageViewSet

router = DefaultRouter()
router.register(r"locations", LocationViewSet)
router.register(
    r"messages",
    MessageViewSet,
)
router.register(
    r"official-messages",
    OfficialMessageViewSet,
)

urlpatterns = [
    path("", include(router.urls)),
]
