/**
 *Submitted for verification at BscScan.com on 2022-11-09
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

contract TMDE {

    struct tools{
        uint256 assetTag;
        string Type;
        address vendor;
        bool inUse;
        bool due; 
        uint256 lastCalibDate;  //last time the tool was serviced
        uint256 nextCalibDate;  //The next time tool needs to be serviced
    }

    tools[] internal TOOLS;

    struct scrapParts{
        uint256 assetTag;
        string Type;
        address vendor;
    }

    scrapParts [] internal ScrapParts;

    address public calibTech1 = 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4;
    address public calibTech2 = 0x3B05C893b88212061C7C4e14c78fcd4E16917BCb;
    address public calibTech3 = 0x3B05C893b88212061C7C4e14c78fcd4E16917BCb;
    address public calibTech4 = 0x6a07bB46D93c4BF298E1aCf67bDBd163e7B793c6;
    address public calibTech5 = 0x6a07bB46D93c4BF298E1aCf67bDBd163e7B793c6;
    address public vendor1 = 0x3B05C893b88212061C7C4e14c78fcd4E16917BCb;
    address public vendor2 = 0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2;
    address public vendor3 = 0x6a07bB46D93c4BF298E1aCf67bDBd163e7B793c6;
    address public manager = 0xdD870fA1b7C4700F2BD7f44238821C26f7392148;

    modifier onlyCalibTech(){
        require(msg.sender == calibTech1 || msg.sender == calibTech2 || msg.sender == calibTech3 ||msg.sender == calibTech4 || msg.sender == calibTech5, "Call: Only Calibration Tech Team");
        _;
    }

    modifier onlyVendor(){
        require(msg.sender == vendor1 || msg.sender == vendor2 || msg.sender == vendor3, "Call: Only Vendor");
        _;
    }
    
    modifier onlyManager(){
        require(msg.sender == manager, "Call: Only Manager");
        _;
    }

        modifier CalibMang(){
        require(msg.sender == calibTech1 || msg.sender == calibTech2 || msg.sender == calibTech3 ||msg.sender == calibTech4 || msg.sender == calibTech5 || msg.sender == manager, "Call: Calibration or Manager Only!");
        _;
    }

  modifier CalibVendMan(){
        require(msg.sender == calibTech1 || msg.sender == calibTech2 || msg.sender == calibTech3 ||msg.sender == calibTech4 || msg.sender == calibTech5 || msg.sender == vendor1 || msg.sender == vendor2 || msg.sender == vendor3 || msg.sender == manager, "Call: Calibration, Vendor, Manager Only!");
        _;
    }

    function createTool(uint256 _assetTag, string memory _Type, address _vendor, bool _status, uint256 _lastCalibDate, uint256 _nextCalibDate) public CalibMang returns (bool){
        for(uint i = 0 ; i<TOOLS.length ; i++){
            require(_assetTag != TOOLS[i].assetTag, "Tool registered already!");
        }
        require(_vendor == vendor1 || _vendor == vendor2 || _vendor == vendor3, "Vendor not Present");
        if(_status == true){
            TOOLS.push(tools(_assetTag, _Type, _vendor, false,true, _lastCalibDate, _nextCalibDate));
        }
        else {
            TOOLS.push(tools(_assetTag, _Type, _vendor, true,false, _lastCalibDate, _nextCalibDate));
        }
        tfMem[_vendor].push(tools(_assetTag, _Type, _vendor, false,true, _lastCalibDate, _nextCalibDate));
        return true;
    }

    function updateTool(uint256 _assetTag, string memory _Type, bool _status, uint256 _lastCalibDate, uint256 _nextCalibDate) public onlyCalibTech onlyManager returns (bool){
        for(uint i = 0 ; i<TOOLS.length ; i++){
            if(TOOLS[i].assetTag == _assetTag){
                if(_status == true){
                    TOOLS[i].due = _status;
                    TOOLS[i].inUse = false;
                }
                else if(_status == false){
                    TOOLS[i].due = _status;
                    TOOLS[i].inUse = true;
                }
                TOOLS[i].Type = _Type;
                TOOLS[i].lastCalibDate = _lastCalibDate;
                TOOLS[i].nextCalibDate = _nextCalibDate;
            }
        }
        return true;
    }

//Tools Info -> Sponsor Wise 
    function toolsInfo() internal view returns(tools[] memory){
        return (tfMem[msg.sender]);
    }

//Show scrap tools Info
    function ScrapToolsInfo() public view returns(scrapParts [] memory){
        return ScrapParts;
    }

//For Calibration and manager to view all tools
    function allToolsInfo() public view CalibVendMan returns( tools [] memory){
        if(msg.sender == vendor1 || msg.sender == vendor2 || msg.sender == vendor3 ){
            toolsInfo();
        }
        else{
        return (TOOLS);
        }
    }

    event DueForCalibration(uint256 indexed assetTag);
    event CalibrationPassed(uint256 assetTag, uint256 _certificate, uint256 _nextCalibDate);
    event calibrationFailed(uint256 assetTag, uint256 _invoice, uint256 _costToService);
    event InvoiceApproved(uint256 _assetTag, uint256 _invoice, uint256 _charges);
    event InvoiceRejected(uint256 _asset);

    enum state {
        Informed, calibPassed, calibFailed, inApproved
    }

    mapping (uint256 => tools) public tagToTool;
    mapping (uint256 => uint256) public serCgs;
    mapping (uint256 => address) public chargesSender;
    mapping (uint256 => state) public STATE;
    mapping (address => tools[]) public tfMem;

    function InformToVendor(uint256 _assetTag) public onlyCalibTech{
        for(uint i = 0 ; i<TOOLS.length ; i++){
            if(TOOLS[i].assetTag == _assetTag){
                TOOLS[i].inUse = false;
                TOOLS[i].due = true;
            }
        }
        STATE[_assetTag] = state.Informed;
        emit DueForCalibration(_assetTag);
    }

    function PassCalibration(uint256 _assetTag, uint256 _certificate, uint256 _nextCalibrationDate) public onlyVendor{
        require (STATE[_assetTag] == state.Informed || STATE[_assetTag] == state.calibFailed);
        for(uint i = 0 ; i<TOOLS.length ; i++){
            if(TOOLS[i].assetTag == _assetTag){
                TOOLS[i].inUse = true;
                TOOLS[i].due = false; 
                TOOLS[i].lastCalibDate = block.timestamp;
                TOOLS[i].nextCalibDate = _nextCalibrationDate;
            }
        }
        STATE[_assetTag] = state.calibPassed;
        emit CalibrationPassed(_assetTag, _certificate, _nextCalibrationDate);
    }

uint256 public currentSerCgs;

    function CalibrationFailed(uint256 _assetTag, uint256 _invoice, uint256 _costToService) public onlyVendor{
        require (STATE[_assetTag] == state.Informed, "You have not been informed yet!");
        serCgs[_assetTag] = _costToService;
        chargesSender[_assetTag] = msg.sender;
        STATE[_assetTag] = state.calibFailed;
        emit calibrationFailed(_assetTag, _invoice, _costToService);
    }

    function ApproveInvoice(uint256 _assetTag, uint256 invoice) public payable onlyManager{
        require (STATE[_assetTag] == state.calibFailed, "Calibration was not failed!");
        require (msg.value == serCgs[_assetTag], "Kindly, check the service charges again!");
        address rec = chargesSender[_assetTag];
        payable(rec).transfer(msg.value);
        STATE[_assetTag] = state.inApproved;
        emit InvoiceApproved(_assetTag, invoice, msg.value);
    }

    function RejectInvoice(uint256 _assetTag) public onlyManager{
        require (STATE[_assetTag] == state.calibFailed, "Calibration was not failed!");
        for(uint i = 0 ; i<TOOLS.length ; i++){
            if(TOOLS[i].assetTag == _assetTag){
                string memory _type = TOOLS[i].Type;
                address _vendorAdd = TOOLS[i].vendor;
                ScrapParts.push(scrapParts(_assetTag, _type, _vendorAdd));
                delete TOOLS[i] ;
            }
        }
        emit InvoiceRejected(_assetTag);
    }

    function changeAddresses(address c1, address c2, address c3, address c4, address c5,
    address v1, address v2, address v3) public onlyManager returns(bool) {
        calibTech1 = c1;
        calibTech2 = c2;
        calibTech3 = c3;
        calibTech4 = c4;
        calibTech5 = c5;
        vendor1 = v1;
        vendor2 = v2;
        vendor3 = v3;
        return true;
    }

    function changeManager(address _manager) public onlyManager returns(bool) {
        manager = _manager;
        return true;
    }
}