/**
 * A custom Pager that maintains a set page size and displays page
numbers and
 * total pages more elegantly. SimplePager will ensure <code>pageSize</code>
 * rows are always rendered even if the "last" page has less than
 * <code>pageSize</code> rows remain.
 */

package com.googlecode.mgwt.examples.showcase.client.custom.jobs;

import com.google.gwt.i18n.client.NumberFormat;
import com.google.gwt.user.cellview.client.SimplePager;
import com.google.gwt.view.client.HasRows;
import com.google.gwt.view.client.Range;

public class CustomSimplePager extends SimplePager {

    //Page size is normally derived from the visibleRange
    private int pageSize;
        
    public CustomSimplePager(int pageSize, SimplePager.TextLocation location, SimplePager.Resources resources, boolean showFastForwardButton, int fastForwardRows, boolean showLastPageButton)
    {
    	this.pageSize = pageSize;
    }

    public void setPageSize(int pageSize) {
        this.pageSize = pageSize;
        super.setPageSize( pageSize );
    }

    // We want pageSize to remain constant
    public int getPageSize() {
        return pageSize;
    }

    // Page forward by an exact size rather than the number of visible
    // rows as is in the norm in the underlying implementation
    public void nextPage() {
        if ( getDisplay() != null ) {
            Range range = getDisplay().getVisibleRange();
            setPageStart( range.getStart()
                          + getPageSize() );
        }
    }

    // Page back by an exact size rather than the number of visible rows
    // as is in the norm in the underlying implementation
    public void previousPage() {
        if ( getDisplay() != null ) {
            Range range = getDisplay().getVisibleRange();
            setPageStart( range.getStart()
                          - getPageSize() );
        }
    }

    // Override so the last page is shown with a number of rows less
    // than the pageSize rather than always showing the pageSize number
    // of rows and possibly repeating rows on the last and last but one
    // page
    public void setPageStart(int index) {
        if ( getDisplay() != null ) {
            Range range = getDisplay().getVisibleRange();
            int displayPageSize = getPageSize();
            if ( isRangeLimited()
                 && getDisplay().isRowCountExact() ) {
                displayPageSize = Math.min( getPageSize(),
                                            getDisplay().getRowCount()
                                                    - index );
            }
            index = Math.max( 0,
                              index );
            if ( index != range.getStart() ) {
                getDisplay().setVisibleRange( index,
                                              displayPageSize );
            }
        }
    }

    // Override to display "0 of 0" when there are no records (otherwise
    // you get "1-1 of 0") and "1 of 1" when there is only one record
    // (otherwise you get "1-1 of 1"). Not internationalized (but
    // neither is SimplePager)
    protected String createText() {
        NumberFormat formatter = NumberFormat.getFormat( "#,###" );
        HasRows display = getDisplay();
        Range range = display.getVisibleRange();
        int pageStart = range.getStart() + 1;
        int pageSize = range.getLength();
        int dataSize = display.getRowCount();
        int endIndex = Math.min( dataSize,
                                 pageStart
                                         + pageSize
                                         - 1 );
        endIndex = Math.max( pageStart,
                             endIndex );
        boolean exact = display.isRowCountExact();
        if ( dataSize == 0 ) {
            return "0 of 0";
        } else if ( pageStart == endIndex ) {
            return formatter.format( pageStart )
                   + " of "
                   + formatter.format( dataSize );
        }
        return formatter.format( pageStart )
               + "-"
               + formatter.format( endIndex )
               + (exact ? " of " : " of over ")
               + formatter.format( dataSize );
    }

}