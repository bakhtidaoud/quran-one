from django.urls import path
from rest_framework_simplejwt.views import (
    TokenBlacklistView,
    TokenObtainPairView,
    TokenRefreshView,
)

from .views import DeleteAccountView, MeView, ProfileView, RegisterView

urlpatterns = [
    path("register", RegisterView.as_view(), name="register"),
    path("login", TokenObtainPairView.as_view(), name="login"),
    path("refresh", TokenRefreshView.as_view(), name="refresh"),
    path("logout", TokenBlacklistView.as_view(), name="logout"),
    path("me", MeView.as_view(), name="me"),
    path("me/profile", ProfileView.as_view(), name="profile"),
    path("me/delete", DeleteAccountView.as_view(), name="delete-account"),
]
