
Simple app to demonstrate ContactsSearchDisplayController.

Spec:

    ContactsManager:
    ---------------
    - Role:
    - Manages an autocomplete text field of unique first_last names of people in the phones contact list.
    - When selection of autocomplete results is clicked calls delegate with contact.
    - Only adds valid phone numbers to contact.

    - Contact:
    {firstName, lastName, phoneNumbers:[{phoneType, phoneNumber}, {}...]
    phoneType = mobile, work, etc...

    ABRecord (instead of above "Contact" object") object is fine as long as:
    - Better yet provide a method to test whether a phone is valid

    In Any Case
    Autocomplete should complete from a universe of all contacts in the addressbook regardless of whether they have a valid phone number.


Usage Notes:

    All Contact searching happens in the ContactsSearchDisplayController object,
        which can be used unmodified in any project.
    ViewController.m shows how to add a ContactsSearchDisplayController to your view.
    ViewController.m also demonstrates the callback/delegate protocol.


TODO:/FIXME:

    //* FIXME: Use Sani's library routines to actually validate the phone #
    //      Current code counts any non-nil phone# as valid

    //* FIXME: If we want to do any sorting, do it here.
    The contacts list is currently sorted by the search controller, which
        appears to use the display strings and a simple dictionary-alphabetical
        sort.

    //* FIXME: do correct filtering, as desired
    There is no filtering of contacts, though this was later added as part of
        the spec, so maybe not a fixme.
