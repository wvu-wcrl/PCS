/*
 * File: CustomWidgets.java

Purpose: Any custom widgets developed can be placed in this java file
**********************************************************/

package com.wcrl.web.cml.client.login;

import com.google.gwt.event.dom.client.ClickEvent;
import com.google.gwt.event.dom.client.ClickHandler;
import com.google.gwt.user.client.ui.Button;
import com.google.gwt.user.client.ui.DialogBox;
import com.google.gwt.user.client.ui.HasAlignment;
import com.google.gwt.user.client.ui.Label;
import com.google.gwt.user.client.ui.VerticalPanel;
import com.google.gwt.widgetideas.client.GlassPanel;

public class CustomWidgets
{
	private GlassPanel glassPanel = new GlassPanel(true);
	private DialogBox alertDialog;
	
	//Alert dialog box
	public void alertWidget(String header, String content) 
	{
        alertDialog = new DialogBox();
        VerticalPanel panel = new VerticalPanel();
        alertDialog.setText(header);
        panel.add(new Label(content));
        final Button buttonClose = new Button("Close");
        buttonClose.addClickHandler(new ClickHandler() 
        {
            public void onClick(ClickEvent event) 
            {
                //box.hide();
            	hideAlert();
            }
        });
        Label emptyLabel = new Label("");
        emptyLabel.setSize("auto","25px");
        panel.add(emptyLabel);
        panel.add(emptyLabel);
        buttonClose.setWidth("90px");
        panel.add(buttonClose);
        panel.setCellHorizontalAlignment(buttonClose, HasAlignment.ALIGN_RIGHT);
        alertDialog.add(panel);
        alertDialog.center();
    }
		
	public void hideAlert()
	{
		if (glassPanel != null) 
		{
			glassPanel.removeFromParent();			
		}
		alertDialog.hide();
	}
}
