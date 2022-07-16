/**
 *Submitted for verification at BscScan.com on 2022-07-16
*/

//// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
contract administrator {
    address private  owner;
    event OwnerSet(address indexed oldOwner, address indexed newOwner);
    
    // modifier to check if caller is owner
    modifier isOwner() {
        // If the first argument of 'require' evaluates to 'false', execution terminates and all
        // changes to the state and to Ether balances are reverted.
        // This used to consume all gas in old EVM versions, but not anymore.
        // It is often a good idea to use 'require' to check if functions are called correctly.
        // As a second argument, you can also provide an explanation about what went wrong.
        require(msg.sender == owner, "Caller is not owner");
        _;
    }
    
    /**
     * @dev Set contract deployer as owner
     */
    constructor() {
        owner = msg.sender; // 'msg.sender' is sender of current call, contract deployer for a constructor
        permission[msg.sender] = true;
        emit OwnerSet(address(0), owner);
    }

    /**
     * @dev Change owner
     * @param newOwner address of new owner
     */
    function changeOwner(address newOwner) public isOwner {
        emit OwnerSet(owner, newOwner);
        owner = newOwner;
    }

    /**
     * @dev Return owner address 
     * @return address of owner
     */
    function getOwner() external view returns (address) {
        return owner;
    }
    mapping (address => bool)  private permission;
    mapping (string  => bool)  private TokenNamepermission;
    mapping (address => bool)  private transferpermission;

    uint256 private _commissionRate=30;
    address private DaoAddress=address(0xA3aF9f9040c4ba6aF2850f9f2cfbCB6dF7A5e11f);
    address private TdbAddress=address(0x2455912CEdc70b107976E0D479BBD8d9Cc6d03A1);
    address private Membship=address (0xCC5b1Dd7E707AE99C3D313D69962991F711abc1F);
    address private tokendata=address (0xF3E18A541a8cFcec66163639655C92ADe5183EEE);  
    address private Tokenmanagement=address (0x7603bd056804555374cB34cBbCD437DD13c75715);
    address private usdaddress=address (0x26720c2a6fa270d7d6EA1a963C4D8f3b9EC5a492);
    address private mathaddress=address (0x76443b0E42eeF1DF9fCDC9B155294955d66AdC6b);

    function licenceSet(address _who,bool  enable) public  returns (bool) {
        require(permission[msg.sender]==true);
        permission[ _who] = enable;
        return permission[ _who];
    }
 
    function TokenNamepermissionSet(string memory  _name,bool _state) public  returns (bool) {
        require(permission[msg.sender]==true);
        TokenNamepermission[_name] = _state;
        return true;
    }

    function transferpermissionSet(address _who,bool  enable) public  returns (bool) {
        require(permission[msg.sender]==true);
        transferpermission[_who] = enable;
        return true;
    }

    function commissionSet(uint256 commissionRate) public isOwner returns (bool success) {
     require(permission[msg.sender]==true);
     require(commissionRate<100);   
    _commissionRate=commissionRate;
    return true;   
    }

    function DaoAddressSet(address _who) public isOwner returns (bool) {
        require(permission[msg.sender]==true);
        DaoAddress = _who;
        transferpermission[_who]=true;
        return true;
    }

    function TdbAddressSet(address _who) public isOwner returns (bool) {
        require(permission[msg.sender]==true);
        TdbAddress =  _who;
        transferpermission[_who]=true;
       return true;
    }  

    function tokendatabaseSet(address _who) public isOwner returns (bool) {
        require(permission[msg.sender]==true);
        tokendata = _who;
        return true;
    }
 
    function MembshipSet(address _who) public isOwner returns (bool) {
        require(permission[msg.sender]==true);
        Membship = _who;
        return true;
    }

    function BaseTokenmanagementSet(address _who) public isOwner returns (bool) {
        require(permission[msg.sender]==true);
        Tokenmanagement = _who;
        return true;
    }

    function usdaddressSet(address _who) public isOwner returns (bool) {
        require(permission[msg.sender]==true);
        usdaddress = _who;
        return true;
    }

    function mathaddressSet(address _who) public isOwner returns (bool) {
        require(permission[msg.sender]==true);
        mathaddress = _who;
        return true;
    }

    function Qmathaddress() public view virtual returns (address _mathaddress) {
        return mathaddress;
    } 

    function Qusdaddress() public view virtual returns (address _usdaddress) {
        return usdaddress;
    }  

    function QBaseTokenmanagement() public view virtual returns (address _BaseTokenmanagement) {
        return Tokenmanagement;
    }  

    function Qtokendatabase() public view virtual returns (address _tokendatabase) {
        return tokendata;
    }  

    function QMembship() public view virtual returns (address _Membship) {
        return Membship;
    }  

    function qtransferpermission(address _who) public view virtual returns (bool) {
        return transferpermission[ _who];
    }

    function licence(address _who) public view virtual returns (bool) {
        return permission[ _who];
    }

    function QDaoAddress() public view virtual returns (address _DaoAddress) {
        return DaoAddress;
    }

    function QTdbAddress() public view virtual returns (address _TdbAddress) {
        return TdbAddress;
    }  

    function Qcommission() public view virtual returns (uint  ommissionRate_) {
        return _commissionRate;
    }

    function QTokenNamepermission(string memory _name) public view virtual returns (bool _state) {
       return TokenNamepermission[_name];
    }
}