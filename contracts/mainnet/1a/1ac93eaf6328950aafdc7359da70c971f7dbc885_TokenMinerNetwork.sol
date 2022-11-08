/**
 *Submitted for verification at BscScan.com on 2022-11-08
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return payable(address(msg.sender));
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
        * @dev Initializes the contract setting the deployer as the initial owner.
        */
    constructor ()  {
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
}

contract TokenMinerNetwork is Context, Ownable {
    using SafeMath for uint256;

    string public constant name = "TokenMinerNetwork";
    string public constant symbol = "TMN";
    uint8 public constant decimals = 18;

    mapping(address => uint256) _balances;

    mapping(address => mapping(address => uint256)) _allowed;

    uint256 _totalSupply;
    uint256 _circulatingSupply;
    uint256 _burnedSupply;

    address _ownerAddress = 0x3D737C129FA566C99Ff462f725EdCE932533071C;
    address _burnAddress = 0x000000000000000000000000000000000000dEaD;

    uint _burnFee = 5;
    uint _claimFee = 10;

    uint256 _minerPrice = 50000000000000000000;

    mapping(address => uint256) _claimableTokens;

    constructor() {
        uint256 initialSupply = 1000000000000000000000;

        _totalSupply = initialSupply;
        _circulatingSupply = initialSupply;
        _burnedSupply = 0;

        _balances[msg.sender] = _totalSupply;
    }

    function totalSupply() public view returns(uint256) {
        return _totalSupply;
    }

    function circulatingSupply() public view returns(uint256) {
        return _circulatingSupply;
    }

    function burnedSupply() public view returns(uint256) {
        return _burnedSupply;
    }

    function balanceOf(address tokenOwner) public view returns(uint256){
        return _balances[tokenOwner];
    }

    function burnFee() public view returns(uint256) {
        return _burnFee;
    }

    function claimFee() public view returns(uint256){
        return _claimFee;
    }

    function minerPrice() public view returns(uint256) {
        return _minerPrice;
    }

    function claimableTokens(address account) public view returns(uint256) {
        return _claimableTokens[account];
    }

    function transfer(address receiver, uint256 numTokens) public returns(bool) {
        require(numTokens <= _balances[msg.sender]);

        _balances[msg.sender] = _balances[msg.sender].sub(numTokens);

        numTokens = burnTokens(numTokens);

        _balances[receiver] = _balances[receiver].add(numTokens);

        emit Transfer(msg.sender, receiver, numTokens);

        return true;
    }

    function approve(address delegate, uint256 numTokens) public returns (bool) {
        _allowed[msg.sender][delegate] = numTokens;

        emit Approval(msg.sender, delegate, numTokens);

        return true;
    }

    function allowance(address owner, address delegate) public view returns (uint256) {
        return _allowed[owner][delegate];
    }

    function transferFrom(address owner, address buyer, uint256 numTokens) public returns (bool) {
        require(numTokens <= _balances[owner]);
        require(numTokens <= _allowed[owner][msg.sender]);

        _balances[owner] = _balances[owner].sub(numTokens);
        _allowed[owner][msg.sender] = _allowed[owner][msg.sender].sub(numTokens);

        numTokens = burnTokens(numTokens);

        _balances[buyer] = _balances[buyer].add(numTokens);

        emit Transfer(owner, buyer, numTokens);

        return true;
    }

    function buyMiner() public{
        require(_balances[msg.sender] >= _minerPrice);

        _balances[msg.sender] = _balances[msg.sender].sub(_minerPrice);

        _circulatingSupply = _circulatingSupply.sub(_minerPrice);
        _burnedSupply = _burnedSupply.add(_minerPrice);

        _balances[_burnAddress] = _balances[_burnAddress].add(_minerPrice);

        emit Transfer(msg.sender, _burnAddress, _minerPrice);
    }

    function burnTokens(uint256 numTokens) private returns(uint256) {
        uint256 burnAmount = getFeeAmount(numTokens, _burnFee);

        _circulatingSupply = _circulatingSupply.sub(burnAmount);
        _burnedSupply = _burnedSupply.add(burnAmount);

        _balances[_burnAddress] = _balances[_burnAddress].add(burnAmount);

        emit Transfer(address(this), _burnAddress, burnAmount);

        return numTokens.sub(burnAmount);
    }

    function getFeeAmount(uint256 numTokens, uint256 feeType) private pure returns(uint256) {
        uint256 amount = numTokens * feeType / 100;
        
        return amount;
    }

    function addClaimableTokens(address account, uint256 tokens) public{
        require(msg.sender == _ownerAddress);
        _claimableTokens[account] = _claimableTokens[account].add(tokens);
    }

    function claimRewards() public returns(bool) {
        uint256 tokens = _claimableTokens[msg.sender];
        _claimableTokens[msg.sender] = 0;

        _totalSupply = _totalSupply.add(tokens);
        _circulatingSupply = _totalSupply.add(tokens);

        uint256 claimAmount = sendClaimFee(tokens);

        _balances[msg.sender] = _balances[msg.sender].add(claimAmount);

        emit Transfer(address(this), msg.sender, claimAmount);

        return true;
    }

    function sendClaimFee(uint256 numTokens) private returns(uint256) {
        uint256 claimAmount = getFeeAmount(numTokens, _claimFee);

        _balances[_ownerAddress] = _balances[_ownerAddress].add(claimAmount);

        emit Transfer(address(this), _ownerAddress, claimAmount);

        return numTokens.sub(claimAmount);
    }

    function setMinerPrice(uint256 price) public {
        require(msg.sender == _ownerAddress);
        _minerPrice = price;
    }

    event Approval(address indexed tokenOwner, address indexed spender, uint256 tokens);
    event Transfer(address indexed from, address indexed to, uint256 tokens);
}

library SafeMath { 
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
      assert(b <= a);
      return a - b;
    }
    
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
      uint256 c = a + b;
      assert(c >= a);
      return c;
    }
}