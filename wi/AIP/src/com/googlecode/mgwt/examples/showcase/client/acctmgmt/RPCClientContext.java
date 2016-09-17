package com.googlecode.mgwt.examples.showcase.client.acctmgmt;

import com.google.gwt.user.client.rpc.IsSerializable;

public class RPCClientContext {
	
	private static ClientContext ctx;

	public static void set(IsSerializable object) {
		ctx = (ClientContext) object;
		
	}

	public static IsSerializable get() {
		// TODO Auto-generated method stub
		return ctx;
	}

}
