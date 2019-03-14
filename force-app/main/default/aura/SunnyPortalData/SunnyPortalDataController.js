({
    getPlantList : function(component, event) {

            var action = component.get("c.getResponse");
        
            component.find("accordion").set('v.activeSectionName', 'A');

            action.setParams({
                portalUser : component.get("v.user"),
                portalPass : component.get("v.password"),
                serviceName : 'plantlist'
            });
            
            action.setCallback(this, function(response) {
                var state = response.getState();           
                if (state === "SUCCESS") {
                    component.set("v.plants", response.getReturnValue());

                }
            });
    
            $A.enqueueAction(action);
            let plantbutton = event.getSource();
            plantbutton.set('v.disabled',true);
    },

    getPlantDevices : function(component, event, helper) {
        component.find("accordion").set('v.activeSectionName', 'B');
        var selPlantName = event.getSource().get("v.value").objName;
        var selPlantOid = event.getSource().get("v.value").objOid;
        component.set("v.selectedPlantName", selPlantName );
        component.set("v.selectedPlantOid", selPlantOid );
        var action = component.get("c.getResponse");

        action.setParams({
            portalUser : component.get("v.user"),
            portalPass : component.get("v.password"), 
            plantOid : selPlantOid,
            serviceName : 'devicelist'
            
        });
               
        action.setCallback(this, function(response) {
            var state = response.getState();           
            if (state === "SUCCESS") {
                component.set("v.devices", response.getReturnValue());
            }
        });
        $A.enqueueAction(action);
        let devicebutton = event.getSource();
        devicebutton.set('v.disabled',true);
        
    },

    getDeviceDataResult : function(component, event){
        component.find("accordion").set('v.activeSectionName', 'C');
        var selDeviceName = event.getSource().get("v.value").deviceName;
        var selDeviceOid = event.getSource().get("v.value").deviceOid;
        //var plantOid = component.get("v.selectedPlantOid");
        component.set("v.selectedDevice", selDeviceName);
        
        var action = component.get("c.getDeviceData");

        action.setParams({
            portalUser : component.get("v.user"),
            portalPass : component.get("v.password"), 
            plantOid : component.get("v.selectedPlantOid"),
            deviceOid : selDeviceOid
            
        });
               
        action.setCallback(this, function(response) {
            var state = response.getState();           
            if (state === "SUCCESS") {
                component.set("v.deviceData", response.getReturnValue());

            }
        });
        $A.enqueueAction(action);
     
    }
        
})