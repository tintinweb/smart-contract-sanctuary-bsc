/**
 *Submitted for verification at BscScan.com on 2022-07-04
*/

// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.6.5;


contract Context {

  constructor () internal { }

  function _msgSender() internal view returns (address payable) {
    return msg.sender;
  }

  function _msgData() internal view returns (bytes memory) {
    this; 
    return msg.data;
  }
}

contract Ownable is Context {
  address private _owner;

  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

  constructor () internal {
    address msgSender = _msgSender();
    _owner = msgSender;
    emit OwnershipTransferred(address(0), msgSender);
  }

  function owner() public view returns (address) {
    return _owner;
  }

  modifier onlyOwner() {
    require(_owner == _msgSender(), "Ownable: caller is not the owner");
    _;
  }

  function renounceOwnership() public onlyOwner {
    emit OwnershipTransferred(_owner, address(0));
    _owner = address(0);
  }

  function transferOwnership(address newOwner) public onlyOwner {
    _transferOwnership(newOwner);
  }

  function _transferOwnership(address newOwner) internal {
    require(newOwner != address(0), "Ownable: new owner is the zero address");
    emit OwnershipTransferred(_owner, newOwner);
    _owner = newOwner;
  }
}

contract Pausable is Ownable {
  event Pause();
  event Unpause();

  bool public paused = false;

  modifier whenNotPaused() {
    require(!paused);
    _;
  }

  modifier whenPaused() {
    require(paused);
    _;
  }

  function pause() onlyOwner whenNotPaused public {
    paused = true;
    Pause();
  }

  function unpause() onlyOwner whenPaused public {
    paused = false;
    Unpause();
  }
}

library Address {
    function isContract(address account) internal view returns (bool) {
        uint256 size;
        assembly { size := extcodesize(account) }
        return size > 0;
    }
}

interface IDataContract{
  function _userdata(address _token, address _userAddr) external view returns (address roots, uint256 recommends);
  function UpdateUserData(address _token, address _userAddr, bool _valid) external;
}

contract DataContract is  Context,  Pausable{

    struct UserData {
        address rootAddr;
        uint256 recommend;
        uint256 validnumber;
        bool valid;
    }

    mapping(address => mapping(address => UserData)) public _userdata;
    address[] public tokens;

    mapping(address => address) public _tokenpower;
    mapping(address => mapping(address => address[])) public _uservalid;
    mapping(address => mapping(address => address[])) public _userrecommends;

/*******************************************************public onlyOwner ************************/
    function AddToken(address _token) public onlyOwner {
        require(_token != address(0), "Cannot set to the zero address");
        if (!isToken(_token)) {
            tokens.push(_token);
        }
    }

    function SetTokenPower(address _token, address _power) public onlyOwner {
        require(_power != address(0), "Cannot set to the zero address");
        require(isToken(_token), "token is no set");
        _tokenpower[_token] = _power;
    }

    function RemoveToken(address _token) public onlyOwner {
        for (uint256 i = 0; i < tokens.length; i++) {
            if (_token == tokens[i]) {
                // remove it
                if (i != tokens.length - 1) {
                    tokens[i] = tokens[tokens.length - 1];
                }
                tokens.pop();
                break;
            }
        }
    }

    function WriteUsersData(address _token, address[] memory _rootAddr, address[] memory _userAddr, bool[] memory _valid) public onlyOwner{
        require(_rootAddr.length == _userAddr.length, "data len no eq");
        require(_userAddr.length == _valid.length, "data len no eq");
        require(isToken(_token), "token is no set");
        for (uint i = 0; i < _rootAddr.length; i++){
          address oldroot = _userdata[_token][_userAddr[i]].rootAddr;
          bool oldvalid = _userdata[_token][_userAddr[i]].valid;
          if ( _rootAddr[i] != oldroot && _rootAddr[i] != address(0) && _rootAddr[i] != _userAddr[i]){
            if(oldroot != address(0)){
              RemoveRecommend(_token, oldroot, _userAddr[i]);
              if (oldvalid){
                RemoveValid(_token, oldroot, _userAddr[i]);
              }
            }
            AddRecommend(_token, _rootAddr[i], _userAddr[i],_valid[i]);
            if (_valid[i]) {
              AddValid(_token, _rootAddr[i], _userAddr[i]);
            }
          }
        }
    }

    function WriteData(address _olddata,address _token, address[] memory _userAddr) public onlyOwner{
        require(isToken(_token), "token is no set");
        for (uint i = 0; i < _userAddr.length; i++){
          (address oldroot, ) = IDataContract(_olddata)._userdata(_token, _userAddr[i]);
          address oldvalid = _userdata[_token][_userAddr[i]].rootAddr;
          if ( address(0) != oldroot && oldvalid == address(0)){
            AddRecommend(_token, oldroot, _userAddr[i],false);
          }
        }
    }
/**************************************************private ******************************/
    function AddValid(address _token, address _rootAddr, address _userAddr) private {
        _uservalid[_token][_rootAddr].push(_userAddr);
        _userdata[_token][_rootAddr].validnumber +=1;
        _userdata[_token][_userAddr].valid = true;
    }

    function RemoveValid(address _token, address _rootAddr, address _userAddr) private {
        for (uint256 i = 0; i < _uservalid[_token][_rootAddr].length; i++) {
          // remove it
            if (_uservalid[_token][_rootAddr][i] == _userAddr) {
                if (i != _uservalid[_token][_rootAddr].length - 1) {
                    _uservalid[_token][_rootAddr][i] = _uservalid[_token][_rootAddr][tokens.length - 1];
                }
                _uservalid[_token][_rootAddr].pop();
                _userdata[_token][_rootAddr].validnumber -=1;
                _userdata[_token][_userAddr].valid = false;
                break;
            }
        }
    }

    function AddRecommend(address _token, address _rootAddr, address _userAddr,bool _valid) private {
        if (_rootAddr != _userAddr){
            _userdata[_token][_userAddr].rootAddr = _rootAddr;
            _userdata[_token][_userAddr].valid = _valid;
            _userdata[_token][_rootAddr].recommend += 1;
            _userrecommends[_token][_rootAddr].push(_userAddr);
        } 
    }

    function RemoveRecommend(address _token, address _rootAddr, address _userAddr) private {
        for (uint256 i = 0; i < _userrecommends[_token][_rootAddr].length; i++) {
          // remove it
            if (_userrecommends[_token][_rootAddr][i] == _userAddr) {
                if (i != _userrecommends[_token][_rootAddr].length - 1) {
                    _userrecommends[_token][_rootAddr][i] = _userrecommends[_token][_rootAddr][tokens.length - 1];
                }
                _userrecommends[_token][_rootAddr].pop();
                _userdata[_token][_rootAddr].recommend -=1;
                _userdata[_token][_userAddr].rootAddr = address(0);
                break;
            }
        }
    }
/*********************************************************************public ****************************************************/
    function NewData(address _rootAddr, address _userAddr) whenNotPaused public {
        if (isToken(msg.sender)) {
            if(_userdata[msg.sender][_userAddr].rootAddr == address(0)){
                if(_userdata[msg.sender][_userAddr].recommend == 0){
                    AddRecommend(msg.sender, _rootAddr, _userAddr, false);                  
                }
            }
        }
    }

    function UpdateUserData(address _token, address _userAddr, bool _valid) public {
      require(_tokenpower[_token] == msg.sender, "only call by set power of token");
      if(_userdata[_token][_userAddr].rootAddr != address(0) && (_valid != _userdata[_token][_userAddr].valid)){
        address rootAddr = _userdata[_token][_userAddr].rootAddr;
        if(_valid){
          AddValid(_token, rootAddr, _userAddr);
        }else{
          RemoveValid(_token, rootAddr, _userAddr);
        }
        _userdata[_token][_userAddr].valid = _valid;
      }
    }
/*****************************************************public view*********************** *******************************/
    function isToken(address who) public view returns (bool) {
        for (uint256 i = 0; i < tokens.length; i++) {
            if (tokens[i] == who) {
                return true;
            }
        }
        return false;
    }

    function GetUserData(address _token, address _userAddr) public view returns (
      address rootAddr,
      uint256 recommend,
      uint256 validnumber,
      bool valid,
      address[] memory validrecommends) {
      rootAddr = _userdata[_token][_userAddr].rootAddr;
      recommend = _userdata[_token][_userAddr].recommend;
      validnumber = _userdata[_token][_userAddr].validnumber;
      valid = _userdata[_token][_userAddr].valid;
      validrecommends =_uservalid[_token][_userAddr];
    }

    function GetRoots(address _token, address _userAddr) public view returns (address[30] memory roots, uint256[30] memory recommends){
        address userAddr = _userAddr;
        for (uint256 i = 0; i < 30; i++) {
            roots[i] = _userdata[_token][userAddr].rootAddr;
            recommends[i] = _userdata[_token][roots[i]].validnumber;
            userAddr = roots[i];
        }
    }
}