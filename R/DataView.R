
UpdateDFView <- function()
{
    DEenv$dfview[,] <- DEenv$Data
}

DataEntryDlg <- function(...)
{
    if(length(DEenv$VarAttr) < 2){
        gmessage(gettext("You can enter data only after setting the variables.",
                         domain = "R-DataEntry"), type = "warning")
        return(invisible(NULL))
    }

    if(!is.null(DEenv$dataw)){
        focus(DEenv$dataw)
        return(invisible(NULL))
    }

    onDestroy <- function(...)
    {
        if(!is.null(DEenv$roww))
            dispose(DEenv$roww)
        rm(list = "dataw", envir = DEenv)
    }

    DEenv$dataw <- gwindow(gettext("View and edit data", domain = "R-DataEntry"),
                           handler = onDestroy, visible = FALSE)
    g <- ggroup(horizontal = FALSE, container = DEenv$dataw)
    DEenv$dfview <- gtable(DEenv$Data, container = g, expand = TRUE)
    g1 <- ggroup(container = g)
    addSpring(g1)
    btEdit <- gbutton(gettext("Edit row", domain = "R-DataEntry"), container = g1)
    btDelete <- gbutton(gettext("Delete row", domain = "R-DataEntry"), container = g1)
    btAdd <- gbutton(gettext("Add row", domain = "R-DataEntry"), container = g1)
    addSpring(g1)
    btClose <- gbutton(gettext("Close", domain = "R-DataEntry"), container = g1)

    onBtDeleteClick <- function(...)
    {
        n <- svalue(DEenv$dfview)
        DEenv$Data <- DEenv$Data[DEenv$Data$id != n, ]
        UpdateDFView()
        SaveProject()
    }

    addHandlerClicked(btEdit,   function(...) RowDlg(FALSE))
    addHandlerClicked(btDelete, onBtDeleteClick)
    addHandlerClicked(btAdd,    function(...) RowDlg())
    addHandlerClicked(btClose,  function(...) dispose(DEenv$dataw))
    UpdateDFView()
    visible(DEenv$dataw) <- TRUE
}
