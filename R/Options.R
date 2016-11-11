
OptionsDlg <- function(...)
{
    if("optw" %in% ls(DEenv)){
        focus(DEenv$optw)
        return(invisible(NULL))
    }

    if(is.null(DEenv$AppOpt))
        GetAppOpt()

    onDestroy <- function(...)
    {
        rm(list = "optw", envir = DEenv)
    }


    DEenv$optw <- gwindow(gettext("Options"), handler = onDestroy, visible = FALSE)
    g <- ggroup(horizontal = FALSE, container = DEenv$optw)

    p <- gframe(gettext("Project options", domain = "R-DataEntry"),
                horizontal = FALSE)

    droplist <- gcheckbox(gettext("Put valid values in dropdown list", domain = "R-DataEntry"),
                       checked = DEenv$ProjOpt$droplist, container = p)
    emptycell <- gcheckbox(gettext("Allow blank cells", domain = "R-DataEntry"),
                       checked = DEenv$ProjOpt$emptycell, container = p)
    gm <- ggroup(container = p)
    glabel(gettext("Text representing missing values: ", domain = "R-DataEntry"),
           container = gm, anchor = c(-1, 1))
    missv <- gedit(DEenv$ProjOpt$missv, width = 4, container = gm)

    if("VarAttr" %in% ls(DEenv))
        add(g, p)

    a <- gframe(gettext("Application options", domain = "R-DataEntry"),
                horizontal = FALSE, container = g)

    bckopen <- gcheckbox(gettext("Backup when opening project",
                               domain = "R-DataEntry"),
                         checked = DEenv$AppOpt$bckopen, container = a)
    bcklast <- gcheckbox(gettext("Keep only the last backups",
                                 domain = "R-DataEntry"),
                         checked = DEenv$AppOpt$bcklast)
    g1 <- ggroup()
    nbckLbl <- glabel(gettext("Number of backups to keep: ", domain = "R-DataEntry"),
                      container = g1, anchor = c(-1, 1))
    nbcks <- gedit(as.character(DEenv$AppOpt$nbcks), width = 3, container = g1)

    addSpring(g)
    g2 <- ggroup(container = g)
    addSpring(g2)
    btDefault <- gbutton(gettext("Default", domain = "R-DataEntry"), container = g2)
    btCancel <- gbutton(gettext("Cancel", domain = "R-DataEntry"), container = g2)
    btOK <- gbutton(gettext("OK", domain = "R-DataEntry"), container = g2)

    SetDefault <- function(...)
    {
        SetDefaultAppOpt()
        SetDefaultProjOpt()
    }

    SetOptions <- function(...)
    {
        if(!IsNumericInt(svalue(nbcks), "integer")){
            focus(nbcks)
            return(invisible(NULL))
        }
        if(as.integer(svalue(nbcks)) < 1){
            gmessage(gettext("Please, enter a positive integer number.",
                             domain = "R-DataEntry"), type = "warning")
            focus(nbcks)
            return(invisible(NULL))
        }

        if("VarAttr" %in% ls(DEenv)){
            DEenv$ProjOpt$droplist  <- svalue(droplist)
            DEenv$ProjOpt$emptycell <- svalue(emptycell)
            DEenv$ProjOpt$missv     <- svalue(missv)
            SaveProject()
        }
        DEenv$AppOpt$bckopen    <- svalue(bckopen)
        DEenv$AppOpt$bcklast    <- svalue(bcklast)
        DEenv$AppOpt$nbcks      <- as.integer(svalue(nbcks))
        SaveAppOpt()
        dispose(DEenv$optw)
    }

    KeepLast <- function(...)
    {
        delete(a, bcklast)
        delete(a, g1)
        if(svalue(bckopen)){
            add(a, bcklast)
            if(svalue(bcklast))
                add(a, g1)
            else
                delete(a, g1)
        } else {
            delete(a, bcklast)
            delete(a, g1)
        }
    }

    addHandlerChanged(btDefault, SetDefault)
    addHandlerChanged(btCancel, function(...) dispose(DEenv$optw))
    addHandlerChanged(btOK, SetOptions)
    addHandlerChanged(bckopen, KeepLast)
    addHandlerChanged(bcklast, KeepLast)
    KeepLast()
    visible(DEenv$optw) <- TRUE
    focus(btCancel)
}