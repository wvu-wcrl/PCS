/**
 * GWTEventService
 * Copyright (c) 2011 and beyond, strawbill UG (haftungsbeschrnkt)
 *
 * This is free software; you can redistribute it and/or modify it
 * under the terms of the GNU Lesser General Public License as
 * published by the Free Software Foundation; either version 3 of
 * the License, or (at your option) any later version.
 * Other licensing for GWTEventService may also be possible on request.
 * Please view the license.txt of the project for more information.
 *
 * This software is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this software; if not, write to the Free
 * Software Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA
 * 02110-1301 USA, or see the FSF site: http://www.fsf.org.
 */
package com.googlecode.mgwt.examples.showcase.client.custom.jobs;

import de.novanic.eventservice.client.event.Event;
import de.novanic.eventservice.client.event.domain.Domain;
import de.novanic.eventservice.client.event.domain.DomainFactory;

public class ServerGeneratedMessageEvent implements Event
{
    /**
	 * 
	 */
	private static final long serialVersionUID = -4101449351741447945L;	
    private JobItem myServerGeneratedEvent;
    public static final Domain SERVER_MESSAGE_DOMAIN = DomainFactory.getDomain("server_message_domain");

    /**
     * Needed for serialization
     */
    public ServerGeneratedMessageEvent() {
    	
    }
    
    public ServerGeneratedMessageEvent(JobItem myServerGeneratedEvent) 
	{
		this.myServerGeneratedEvent = myServerGeneratedEvent;
	}
    
    public JobItem getMyServerGeneratedEvent() 
    {
		return myServerGeneratedEvent;
	}
}