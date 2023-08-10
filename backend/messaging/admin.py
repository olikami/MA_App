from django.contrib import admin

from messaging.models import Location, Message

admin.site.register(Location)


class MessageAdmin(admin.ModelAdmin):
    list_display = ("content", "author", "sent", "location")
    list_filter = ("sent", "author", "location")
    search_fields = (
        "content",
        "author__username",
    )  # assuming `ApplicationUser` has a field named `username`


admin.site.register(Message, MessageAdmin)
