class Paths
    KEY = "../key"
    EXPECTED = "..//customfieldname[.='Expected']/../customfieldvalues"
    TITLE = "../title"
    TYPE = "../type"

    ### Status
    OPEN = "//status[.='Open']"
    IN_PROGRESS = "//status[.='In Progress']"
    RFR = "//status[.='Ready for Review']"
    RFAT = "//status[.='Ready for Acceptance Testing']"
    CLOSED = "//status[.='Closed']"
    BACKLOG = "//status[.='Backlog']"
end
