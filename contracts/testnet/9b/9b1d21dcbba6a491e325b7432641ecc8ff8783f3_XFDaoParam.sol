/**
 *Submitted for verification at BscScan.com on 2022-05-23
*/

// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

library ArrayUtil {

    function containsAddress(address[] memory array, address a) public pure returns(bool) {
        uint256 l = array.length;
        if(l == 0) {
            return false;
        }else {
            bool f = false;
            for(uint256 i=0; i<l; i++) {
                if(array[i] == a) {
                    f = true;
                    break;        
                }
            }
            return f;
        }
    } 

    function containsAddressIndex(address[] memory array, address a) public pure returns(bool, uint256) {
        uint256 l = array.length;
        if(l == 0) {
            return (false, 0);
        }else {
            bool f = false;
            uint256 index = 0;
            for(uint256 i=0; i<l; i++) {
                if(array[i] == a) {
                    index = i;
                    f = true;
                    break;        
                }
            }
            return (f, index);
        }
    } 

    function containsAddress0(address[] memory array) public pure returns(bool) {
        return containsAddress(array, address(0));
    } 

    function containsAddress0Index(address[] memory array) public pure returns(bool, uint256) {
        return containsAddressIndex(array, address(0));
    } 
        
}

library StringEquals {
    
    function equals(string memory a, string memory b) internal pure returns (bool) {
        return strCompare(a, b) == 0;
    }

    function strCompare(string memory _a, string memory _b) internal pure returns (int _returnCode) {
        bytes memory a = bytes(_a);
        bytes memory b = bytes(_b);
        uint minLength = a.length;
        if (b.length < minLength) {
            minLength = b.length;
        }
        for (uint i = 0; i < minLength; i ++) {
            if (a[i] < b[i]) {
                return -1;
            } else if (a[i] > b[i]) {
                return 1;
            }
        }
        if (a.length < b.length) {
            return -1;
        } else if (a.length > b.length) {
            return 1;
        } else {
            return 0;
        }
    }

    function isEmpty(string memory a) internal pure returns (bool) {
        return equals(a, "");
    }

    function contains(string[] memory array, string memory name) public pure returns(bool, uint256) {
        uint256 l = array.length;
        if(l == 0) {
            return (false, 0);
        }
        bool exist = false;
        uint256 index = 0;
        for(uint256 i=0; i<l; i++) {
            if(equals(name, array[i])){
                exist = true;
                index = i;
                break;
            }
        }
        return (exist, index);
    }
}

contract Context {
    constructor () { }
    // solhint-disable-previous-line no-empty-blocks

    function _msgSender() internal view returns (address) {
        return msg.sender;
    }
}

contract Ownable is Context {
    address public _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

//uint256
interface IXFDaoParamUint256 {
    function addProposalParamUint256(address paramSeq, string memory name, uint256 uValue) external;
    function updateParamUint256Value(address paramSeq) external;
    function getParamUint256Detail(address seq) external view returns(string memory, string memory, uint256, uint256, bool);
}

//uint
interface IXFDaoParamUint {
    function addProposalParamUint(address paramSeq, string memory name, uint uValue) external;
    function updateParamUintValue(address paramSeq) external;
    function getParamUintDetail(address seq) external view returns(string memory, string memory, uint, uint, bool);
}

//string
interface IXFDaoParamString {
    function addProposalParamString(address paramSeq, string memory name, string memory uValue) external;
    function updateParamStringValue(address paramSeq) external;
    function getParamStringDetail(address seq) external view returns(string memory, string memory, string memory, string memory, bool);
}

//address
interface IXFDaoParamAddress {
    function addProposalParamAddress(address paramSeq, string memory name, address uValue) external;
    function updateParamAddressValue(address paramSeq) external;
    function getParamAddressDetail(address seq) external view returns(string memory, string memory, address, address, bool);
}

//bool
interface IXFDaoParamBool {
    function addProposalParamBool(address paramSeq, string memory name, bool uValue) external;
    function updateParamBoolValue(address paramSeq) external;
    function getParamBoolDetail(address seq) external view returns(string memory, string memory, bool, bool, bool);
}

//mapping(address=>uint256) see below.
interface IXFDaoParamMap_Address_Uint256 {
    function getParamAU256Detail(address seq) external view returns(string memory, string memory, uint256, uint256, address, bool);
    function addProposalParamAU256(address paramSeq, string memory name, address from, uint256 uValue) external;
    function updateParamAU256Value(address paramSeq) external;
}

//address[]
interface IXFDaoParamAddressArray {
    function addProposalParamAddressArray(address paramSeq, string memory name, uint action, address uValue) external;
    function updateParamAddressArrayValue(address paramSeq) external;
    function getParamAddressArrayDetail(address seq) external view returns(string memory, string memory, uint, address, bool);
}

interface IXFDaoParam is IXFDaoParamUint256, IXFDaoParamUint, IXFDaoParamString, IXFDaoParamAddress, 
    IXFDaoParamBool, IXFDaoParamMap_Address_Uint256, IXFDaoParamAddressArray{

    function isProposalDoingParams(string memory name) external view returns(bool);
    function paramIsExist(string memory name) external view returns(bool, uint256);
}

//
interface IXFDaoParamData{
    function getParamUint256Value(string memory name) external view returns(uint256);
    function getParamBoolValue(string memory name) external view returns(bool);
    function getParamUintValue(string memory name) external view returns(uint);
    function getParamStringValue(string memory name) external view returns(string memory);
    function getParamAddressValue(string memory name) external view returns(address);
    function getParamAU256Value(string memory name, address from) external view returns(uint256);
    function resetParamAU256(string memory name, address from, uint256 value) external;
    function getParamAddressArrayValue(string memory name) external view returns(address[] memory);
}

contract XFDaoParam is Ownable, IXFDaoParam, IXFDaoParamData{

    using StringEquals for string;
    using ArrayUtil for address[];

    event ParamUint256WasChanged(string name, uint256 cValue, uint256 uValue);
    event ParamUintWasChanged(string name, uint cValue, uint uValue);
    event ParamStringWasChanged(string name, string cValue, string uValue);
    event ParamAddressWasChanged(string name, address cValue, address uValue);
    event ParamAU256WasChanged(string name, address from, uint256 cValue, uint256 uValue);
    event ParamBoolWasChanged(string name, bool cValue, bool uValue);
    event ParamAddressArrayWasChanged(string name, uint action, address uValue);

    uint constant PROPOSAL_TYPE_UINT256 = 0;
    uint constant PROPOSAL_TYPE_UINT = 1;
    uint constant PROPOSAL_TYPE_STRING = 2;
    uint constant PROPOSAL_TYPE_ADDRESS = 3;
    uint constant PROPOSAL_TYPE_AU256 = 4;
    uint constant PROPOSAL_TYPE_BOOL = 5;
    uint constant PROPOSAL_TYPE_ADDRESS_ARRAY = 6;

    mapping(address=>bool) conWhileList;

    bool public initOnce;

    function init() public {
        require(initOnce == false,"DaoParam:already initialize.");
        _owner = msg.sender;
        initOnce = true;
    }

    modifier isContractWhileList {
        address sender = _msgSender();
        require(conWhileList[sender], "no permission.");
        _;
    }

    function setContractWhileList(address con, bool b) public onlyOwner {
        conWhileList[con] = b;
    }

    function contractInWhileList(address con) public view returns(bool) {
        return conWhileList[con];
    }

    string[] paramNames;

    struct BaseParam {
        string nameDes;
        uint paramType;//0:uint256 1:uint 2:string 3:address 4:ua256 5:bool
        bool canUpdateByProposal;
    }

    mapping(string=>BaseParam) paramBases;

    function genBaseParam(string memory nameDes, uint paramType, bool canUpdateByProposal) private pure returns(BaseParam memory) {
        BaseParam memory param = BaseParam({nameDes:nameDes, paramType:paramType, canUpdateByProposal:canUpdateByProposal});
        return param;
    }

    function paramCanUpdateByProposal(string memory name, bool b) public onlyOwner{
        (bool exist, ) = paramIsExist(name);
        require(exist, "error.");
        paramBases[name].canUpdateByProposal = b;
    }

    function paramCanUpdateByProposal(string memory name) public view returns(bool) {
        return paramBases[name].canUpdateByProposal;
    }

    function paramIsExist(string memory name) public view returns(bool, uint256) {
        uint256 l = paramNames.length;
        if(l == 0) {
            return (false, 0);
        }
        bool exist = false;
        uint256 index = 0;
        for(uint256 i=0; i<l; i++) {
            if(name.equals(paramNames[i])){
                exist = true;
                index = i;
                break;
            }
        }
        return (exist, index);
    }

    mapping(string=>bool) proposalDoingParams;

    function isProposalDoingParams(string memory name) public view returns(bool) {
        return proposalDoingParams[name];
    }

    struct ParamUint256 {
        string name;
        uint256 cValue;
        uint256 uValue;
    }

    mapping(string=>ParamUint256) paramsUint256s;

    function addParamUint256(string memory name, string memory nameDes, uint256 cValue, bool canUpdateByProposal) public onlyOwner {
        (bool exist,) = paramIsExist(name);
        require(!exist, "param is exist.");
        paramBases[name] = genBaseParam(nameDes, PROPOSAL_TYPE_UINT256, canUpdateByProposal);
        paramsUint256s[name] = ParamUint256({name:name, cValue:cValue, uValue:cValue});
        paramNames.push(name);
    }

    mapping(address=>ParamUint256) paramsUint256Updates;

    //
    function addProposalParamUint256(address seq, string memory name, uint256 uValue) public isContractWhileList {
        (bool exist, ) = paramIsExist(name);
        require(exist && paramCanUpdateByProposal(name), "error.");
        paramsUint256Updates[seq] = ParamUint256({name:name, cValue:paramsUint256s[name].cValue, uValue:uValue});
        proposalDoingParams[name] = true;
    }

    function updateParamUint256Value(address seq) public isContractWhileList {
        ParamUint256 memory param = paramsUint256Updates[seq];
        (bool exist, ) = paramIsExist(param.name);
        require(exist, "param is not exist.");
        paramsUint256s[param.name].cValue = param.uValue;
        paramsUint256s[param.name].uValue = param.uValue;
        proposalDoingParams[param.name] = false;
        emit ParamUint256WasChanged(param.name, param.cValue, param.uValue);
    }

    function getParamUint256Value(string memory name) public view returns(uint256) {
        (bool exist, ) = paramIsExist(name);
        require(exist, "param is not exist.");
        return paramsUint256s[name].cValue;
    }

    function getParamUint256Detail(address seq) public view returns(string memory, string memory, uint256, uint256, bool) {
        ParamUint256 memory p = paramsUint256Updates[seq];
        BaseParam memory base = paramBases[p.name];
        return(p.name, base.nameDes, p.cValue, p.uValue, base.canUpdateByProposal);
    }

    struct ParamBool {
        string name;
        bool cValue;
        bool uValue;
    }

    mapping(string=>ParamBool) paramsBools;

    function addParamBool(string memory name, string memory nameDes, bool cValue, bool canUpdateByProposal) public onlyOwner {
        (bool exist,) = paramIsExist(name);
        require(!exist, "param is exist.");
        paramBases[name] = genBaseParam(nameDes, PROPOSAL_TYPE_BOOL, canUpdateByProposal);
        paramsBools[name] = ParamBool({name:name, cValue:cValue, uValue:cValue});
        paramNames.push(name);
    }

    mapping(address=>ParamBool) paramsBoolUpdates;

    //
    function addProposalParamBool(address seq, string memory name, bool uValue) public isContractWhileList {
        (bool exist,) = paramIsExist(name);
        require(exist && paramCanUpdateByProposal(name), "error.");
        paramsBoolUpdates[seq] = ParamBool({name:name, cValue:paramsBools[name].cValue, uValue:uValue});
        proposalDoingParams[name] = true;
    }

    function updateParamBoolValue(address seq) public isContractWhileList {
        ParamBool memory param = paramsBoolUpdates[seq];
        (bool exist,) = paramIsExist(param.name);
        require(exist, "param is not exist.");
        paramsBools[param.name].cValue = param.uValue;
        paramsBools[param.name].uValue = param.uValue;
        proposalDoingParams[param.name] = false;
        emit ParamBoolWasChanged(param.name, param.cValue, param.uValue);
    }

    function getParamBoolValue(string memory name) public view returns(bool) {
        (bool exist,) = paramIsExist(name);
        require(exist, "param is not exist.");
        return paramsBools[name].cValue;
    }

    function getParamBoolDetail(address seq) public view returns(string memory, string memory, bool, bool, bool) {
        ParamBool memory p = paramsBoolUpdates[seq];
        BaseParam memory base = paramBases[p.name];
        return(p.name, base.nameDes, p.cValue, p.uValue, base.canUpdateByProposal);
    }

    //uint ------

    struct ParamUint {
        string name;
        uint256 cValue;
        uint256 uValue;
    } 

    mapping(string=>ParamUint) paramsUints;

    function addParamUint(string memory name, string memory nameDes, uint256 cValue, bool canUpdateByProposal) public onlyOwner {
        (bool exist,) = paramIsExist(name);
        require(!exist, "param is exist.");
        paramBases[name] = genBaseParam(nameDes, PROPOSAL_TYPE_UINT, canUpdateByProposal);
        paramsUints[name] = ParamUint({name:name, cValue:cValue, uValue:cValue});
        paramNames.push(name);
    }

    mapping(address=>ParamUint) paramsUintUpdates;

    //
    function addProposalParamUint(address seq, string memory name, uint uValue) public isContractWhileList {
        (bool exist,) = paramIsExist(name);
        require(exist && paramCanUpdateByProposal(name), "error.");
        paramsUintUpdates[seq] = ParamUint({name:name, cValue:paramsUints[name].cValue, uValue:uValue});
        proposalDoingParams[name] = true;
    }

    function updateParamUintValue(address seq) public isContractWhileList {
        ParamUint memory param = paramsUintUpdates[seq];
        (bool exist, ) = paramIsExist(param.name);
        require(exist, "param is not exist.");
        paramsUints[param.name].cValue = param.uValue;
        paramsUints[param.name].uValue = param.uValue;
        proposalDoingParams[param.name] = false;
        emit ParamUintWasChanged(param.name, param.cValue, param.uValue);
    }

    function getParamUintValue(string memory name) public view returns(uint) {
        (bool exist,) = paramIsExist(name);
        require(exist, "param is not exist.");
        return paramsUints[name].cValue;
    }

    function getParamUintDetail(address seq) public view returns(string memory, string memory, uint, uint, bool) {
        ParamUint memory p = paramsUintUpdates[seq];
        BaseParam memory base = paramBases[p.name];
        return(p.name, base.nameDes, p.cValue, p.uValue, base.canUpdateByProposal);
    }    

    //string ------

    struct ParamString {
        string name;
        string cValue;
        string uValue;
    }

    mapping(string=>ParamString) paramsStrings;

    function addParamString(string memory name, string memory nameDes, string memory cValue, bool canUpdateByProposal) public onlyOwner {
        (bool exist,) = paramIsExist(name);
        require(!exist, "param is exist.");
        paramBases[name] = genBaseParam(nameDes, PROPOSAL_TYPE_STRING, canUpdateByProposal);
        paramsStrings[name] = ParamString({name:name, cValue:cValue, uValue:cValue});
        paramNames.push(name);
    }

    mapping(address=>ParamString) paramsStringUpdates;

    //
    function addProposalParamString(address seq, string memory name, string memory uValue) public isContractWhileList {
        (bool exist, ) = paramIsExist(name);
        require(exist && paramCanUpdateByProposal(name), "error.");
        paramsStringUpdates[seq] = ParamString({name:name, cValue:paramsStrings[name].cValue, uValue:uValue});
        proposalDoingParams[name] = true;
    }

    function updateParamStringValue(address seq) public isContractWhileList {
        ParamString memory param = paramsStringUpdates[seq];
        (bool exist, ) = paramIsExist(param.name);
        require(exist, "param is not exist.");
        paramsStrings[param.name].cValue = param.uValue;
        paramsStrings[param.name].uValue = param.uValue;
        proposalDoingParams[param.name] = false;
        emit ParamStringWasChanged(param.name, param.cValue, param.uValue);
    }

    function getParamStringValue(string memory name) public view returns(string memory) {
        (bool exist, ) = paramIsExist(name);
        require(exist, "param is not exist.");
        return paramsStrings[name].cValue;
    }

    function getParamStringDetail(address seq) public view returns(string memory, string memory, string memory, string memory, bool) {
        ParamString memory p = paramsStringUpdates[seq];
        BaseParam memory base = paramBases[p.name];
        return(p.name, base.nameDes, p.cValue, p.uValue, base.canUpdateByProposal);
    }    

    //address ------

    struct ParamAddress {
        string name;
        address cValue;
        address uValue;
    }

    mapping(string=>ParamAddress) paramsAddresss;

    function addAddressParam(string memory name, string memory nameDes, address cValue, bool canUpdateByProposal) public onlyOwner {
        (bool exist,) = paramIsExist(name);
        require(!exist, "param is exist.");
        paramBases[name] = genBaseParam(nameDes, PROPOSAL_TYPE_ADDRESS, canUpdateByProposal);
        paramsAddresss[name] = ParamAddress({name:name, cValue:cValue, uValue:cValue});
        paramNames.push(name);
    }

    mapping(address=>ParamAddress) paramsAddressUpdates;

    //
    function addProposalParamAddress(address seq, string memory name, address uValue) public isContractWhileList {
        (bool exist, ) = paramIsExist(name);
        require(exist && paramCanUpdateByProposal(name), "error.");
        paramsAddressUpdates[seq] = ParamAddress({name:name, cValue:paramsAddresss[name].cValue, uValue:uValue});
        proposalDoingParams[name] = true;
    }

    function updateParamAddressValue(address seq) public isContractWhileList {
        ParamAddress memory param = paramsAddressUpdates[seq];
        (bool exist, ) = paramIsExist(param.name);
        require(exist, "param is not exist.");
        paramsAddresss[param.name].cValue = param.uValue;
        paramsAddresss[param.name].uValue = param.uValue;
        proposalDoingParams[param.name] = false;
        emit ParamAddressWasChanged(param.name, param.cValue, param.uValue);
    }

    function getParamAddressValue(string memory name) public view returns(address) {
        (bool exist, ) = paramIsExist(name);
        require(exist, "param is not exist.");
        return paramsAddresss[name].cValue;
    }

    function getParamAddressDetail(address seq) public view returns(string memory, string memory, address, address, bool) {
        ParamAddress memory p = paramsAddressUpdates[seq];
        BaseParam memory base = paramBases[p.name];
        return(p.name, base.nameDes, p.cValue, p.uValue, base.canUpdateByProposal);
    }


    //au256-----

    struct ParamAu256 {
        string name;
        uint256 cValue;
        uint256 uValue;
        address from;
    }

    mapping(string=>mapping(address=>ParamUint256)) paramsAU256s;

    function addAU256Param(string memory name, string memory nameDes, bool canUpdateByProposal) public onlyOwner {
        (bool exist,) = paramIsExist(name);
        require(!exist, "param is exist.");
        BaseParam memory base = genBaseParam(nameDes, PROPOSAL_TYPE_AU256, canUpdateByProposal);
        paramBases[name] = base;
        paramNames.push(name);
    }

    mapping(address=>ParamAu256) paramsAU256Updates;

    //
    function addProposalParamAU256(address seq, string memory name, address from, uint256 uValue) public isContractWhileList {
        (bool exist,) = paramIsExist(name);
        require(exist && paramCanUpdateByProposal(name), "error.");
        paramsAU256Updates[seq] = ParamAu256({name:name, cValue:paramsAU256s[name][from].cValue, uValue:uValue, from:from});
        proposalDoingParams[name] = true;
    }

    function updateParamAU256Value(address seq) public isContractWhileList {
        ParamAu256 memory param = paramsAU256Updates[seq];
        (bool exist,) = paramIsExist(param.name);
        require(exist, "param is not exist.");
        paramsAU256s[param.name][param.from].cValue = param.uValue;
        paramsAU256s[param.name][param.from].uValue = param.uValue;
        proposalDoingParams[param.name] = false;
        emit ParamAU256WasChanged(param.name, param.from, param.cValue, param.uValue);
    }

    function resetParamAU256(string memory name, address from, uint256 value) public isContractWhileList {
        (bool exist,) = paramIsExist(name);
        require(exist, "param is not exist.");
        paramsAU256s[name][from].cValue = value;
        paramsAU256s[name][from].uValue = value;
    }

    function getParamAU256Detail(address seq) public view returns(string memory, string memory, uint256, uint256, address, bool) {
        ParamAu256 memory p = paramsAU256Updates[seq];
        BaseParam memory base = paramBases[p.name];
        return(p.name, base.nameDes, p.cValue, p.uValue, p.from, base.canUpdateByProposal);
    }

    function getParamAU256Value(string memory name, address from) public view returns(uint256) {
        (bool exist,) = paramIsExist(name);
        require(exist, "param is not exist.");
        return paramsAU256s[name][from].cValue;
    }

    struct ParamAddressArray {
        string name;
        uint action;
        address uValue;
    }

    mapping(string=>address[]) addressArray;

    mapping(string=>ParamAddressArray) paramsAddressArrays;

    function addAddressArrayParam(string memory name, string memory nameDes, bool canUpdateByProposal) public onlyOwner {
        (bool exist,) = paramIsExist(name);
        require(!exist, "param is exist.");
        paramBases[name] = genBaseParam(nameDes, PROPOSAL_TYPE_ADDRESS_ARRAY, canUpdateByProposal);
        paramNames.push(name);
    }

    mapping(address=>ParamAddressArray) paramsAddressArrayUpdates;

    function addProposalParamAddressArray(address seq, string memory name, uint action, address uValue) public isContractWhileList {
        (bool exist, ) = paramIsExist(name);
        require(exist && paramCanUpdateByProposal(name), "error.");
        paramsAddressArrayUpdates[seq] = ParamAddressArray({name:name, action:action, uValue:uValue});
        proposalDoingParams[name] = true;
    }

    function updateParamAddressArrayValue(address seq) public isContractWhileList {
        ParamAddressArray memory param = paramsAddressArrayUpdates[seq];
        (bool exist, ) = paramIsExist(param.name);
        require(exist, "param is not exist.");
        if(param.action == 1) {
            (bool b, uint256 index) = addressArray[param.name].containsAddress0Index();
            if(b) {
                addressArray[param.name][index] = param.uValue;
            }else {
                addressArray[param.name].push(param.uValue);
            }
        }else if(param.action == 2) {
            (bool b, uint256 index) = addressArray[param.name].containsAddressIndex(param.uValue);
            require(b, "action address not found.");
            delete addressArray[param.name][index];
        }

        proposalDoingParams[param.name] = false;
        emit ParamAddressArrayWasChanged(param.name, param.action, param.uValue);
    }

    function getParamAddressArrayValue(string memory name) public view returns(address[] memory) {
        (bool exist, ) = paramIsExist(name);
        require(exist, "param is not exist.");
        return addressArray[name];
    }

    function getParamAddressArrayDetail(address seq) public view returns(string memory, string memory, uint, address, bool) {
        ParamAddressArray memory p = paramsAddressArrayUpdates[seq];
        BaseParam memory base = paramBases[p.name];
        return(p.name, base.nameDes, p.action, p.uValue, base.canUpdateByProposal);
    }

}