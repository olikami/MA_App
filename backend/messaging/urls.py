from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import LocationViewSet, MessageViewSet

router = DefaultRouter()
router.register(r"locations", LocationViewSet)
router.register(
    r"messages",
    MessageViewSet,
)

urlpatterns = [
    path("", include(router.urls)),
]
