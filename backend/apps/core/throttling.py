from rest_framework.throttling import UserRateThrottle


class BurstRateThrottle(UserRateThrottle):
    scope = "burst"


class SustainedRateThrottle(UserRateThrottle):
    scope = "sustained"


class AIRateThrottle(UserRateThrottle):
    """Applied only to AI endpoints, which cost real money per call."""

    scope = "ai"
