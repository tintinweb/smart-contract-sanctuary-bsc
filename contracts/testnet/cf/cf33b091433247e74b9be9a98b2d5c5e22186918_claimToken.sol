/**
 *Submitted for verification at BscScan.com on 2022-05-23
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

interface IERC20 {
    
    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}


abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this;
        // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _setOwner(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

contract claimToken is Context, Ownable{
    mapping(address => bool) _blacklist;
    mapping(address => mapping(address => bool)) _whitelist;

    mapping(address => uint) _token_claim;

    struct UserClaim {
      uint amount;
      bool is_received;
    }

    mapping(address => mapping(address => UserClaim)) _address_claim;


    function withdrawToken(address _tokenContract, uint256 _amount) external onlyOwner {
        IERC20 tokenContract = IERC20(_tokenContract);
        
        tokenContract.transfer(msg.sender, _amount);
    }

    function getAmountToken(address _tokenContract) view public returns (uint) {
        return address(_tokenContract).balance;
    }

    function rescueBNB(uint256 weiAmount) external onlyOwner {
        require(address(this).balance >= weiAmount, "insufficient BNB balance");
        payable(msg.sender).transfer(weiAmount);
    }

    function rescueBEP20Tokens(address _tokenContract) external onlyOwner {
        IERC20(_tokenContract).transfer(msg.sender, IERC20(_tokenContract).balanceOf(address(this)));
    }

//Get and set amount token airdrop
    function getMaxAmountClaimToken(address _tokenContract) view public returns (uint) {
      return _token_claim[_tokenContract];
    }

    function setMaxAmountClaimToken(address _tokenContract, uint _amount) public onlyOwner {
      _token_claim[_tokenContract] = _amount;
    }

    function removeMaxAmountClaimToken(address _tokenContract) public onlyOwner {
      delete(_token_claim[_tokenContract]);
    }
////
//Get and set amount claim airdrop
    function getAddressClaim(address _tokenContract, address _address) view public returns (UserClaim memory) {
        return _address_claim[_tokenContract][_address];
    }

    function getAddressAmountClaimToken(address _tokenContract, address _address) view public returns (uint) {
        if(isWhitelist(_tokenContract, _address)) {
            return _token_claim[_tokenContract];
        }

        if(_address_claim[_tokenContract][_address].is_received) {
            return 0;
        }
        return _address_claim[_tokenContract][_address].amount > _token_claim[_tokenContract] ? _token_claim[_tokenContract] : _address_claim[_tokenContract][_address].amount;
    }

    function setAddressClaim(address _tokenContract, address _address, uint _amount) public onlyOwner {
        _address_claim[_tokenContract][_address].amount = _amount > _token_claim[_tokenContract] ? _token_claim[_tokenContract] : _amount;
        _address_claim[_tokenContract][_address].is_received = false;
    }
////claim

    function isClaim(address _tokenContract, address _address) view public returns (bool) {
        if (_whitelist[_tokenContract][_address] && !_address_claim[_tokenContract][_address].is_received || !_address_claim[_tokenContract][_address].is_received && _address_claim[_tokenContract][_address].amount > 0) {
            return true;
        }

        return false;
    }

    function claim(address _tokenContract) public {
        require(!isBlacklist(msg.sender), "Blacklist: Address in blacklist");
        require(isClaim(_tokenContract, msg.sender), "IsClaim: Not in list claim");
        uint amount = getAddressAmountClaimToken(_tokenContract, msg.sender);
        if(_whitelist[_tokenContract][msg.sender]) {
            _address_claim[_tokenContract][msg.sender].amount = amount;
        }

        _address_claim[_tokenContract][msg.sender].is_received = true;

        IERC20 tokenContract = IERC20(_tokenContract);
    
        tokenContract.transfer(msg.sender, amount);
    }
////

////blacklist
    function isBlacklist(address _address) view public returns (bool) {
        return _blacklist[_address];
    }

    function setBlacklist(address _address) public onlyOwner {
        _blacklist[_address] = true;
    }

    function removeBlacklist(address _address) public onlyOwner {
        delete(_blacklist[_address]);
    }
////

////whitelist
    function isWhitelist(address _tokenContract, address _address) view public returns (bool) {
        return _whitelist[_tokenContract][_address];
    }

    function setWhitelist(address _tokenContract, address _address) public onlyOwner {
        _whitelist[_tokenContract][_address] = true;
    }

    function removeWhitelist(address _tokenContract, address _address) public onlyOwner {
        delete(_whitelist[_tokenContract][_address]);
    }
////
}