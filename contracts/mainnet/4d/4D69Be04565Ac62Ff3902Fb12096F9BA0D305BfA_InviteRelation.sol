/**
 *Submitted for verification at BscScan.com on 2022-09-19
*/

// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _transferOwnership(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}


interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}


contract InviteRelation is Ownable{
    using SafeMath for address;

    uint256 public maxNmbrella;
    struct Referrer {
        address owner;
        uint256 row;
    }
    mapping(address => Referrer) private _referrers;
    mapping(address => address[]) private _umbrellas;

    event CreateReferrer(uint256 indexed userRow, address indexed owner, address indexed user);

    constructor( ) {
        _referrers[address(0)] = Referrer(
            address(this),
            0
        );
    }
    
    function setMaxNmber(uint256 _maxNmbrella) external onlyOwner {
        maxNmbrella =  _maxNmbrella;
    }

    function umbrellaNumOf(address _owner) public view returns(uint256) {
        return _umbrellas[_owner].length;
    }

    function umbrella(address _owner) external view returns(address[] memory) {
        return _umbrellas[_owner];
    }

    function referrer(address _owner) external view returns(address, uint256) {
        return (_referrers[_owner].owner, _referrers[_owner].row);
    }

    function getReferrerFor(address _owner, uint _size) external view returns(address[] memory refs) {
        address[] memory _refs = new address[](_size);
        uint len;
        address owner_refs = _owner;
        for(uint256 i = 0; i < _size; i++) {
            owner_refs = _referrers[owner_refs].owner;
            if ( owner_refs == address(this) || owner_refs == address(0)) break;
            _refs[len] = owner_refs;
                len++;
        }
        refs = new address[](len);
        for(uint256 i = 0; i < len; i++) {
            refs[i] = _refs[i];
        }
    }
    
    function addReferrer(address _referrer_) external {
        _addReferrerFor(_msgSender(),_referrer_);
    }

    function _addReferrerFor(address _owner,address _referrer_) internal {
        Referrer storage _ref = _referrers[_owner];
        Referrer memory _ref_referrers = _referrers[_referrer_];
        require(_referrer_ != _owner, "referrer cannot self");
        require(_referrer_ != address(0), "referrer cannot 0x00");
        require(_ref.owner == address(0), "Referrered");
        require(_ref_referrers.owner != address(0) || _referrer_ == address(this), "referrer need referrered");
        require(_ref_referrers.owner != _owner, "Referrered error");
        _ref.owner = _referrer_;
        _ref.row = _ref_referrers.row + 1;
        _umbrellas[_referrer_].push(
            _owner
        );
        require(maxNmbrella == 0 || umbrellaNumOf(_referrer_) <= maxNmbrella, "maxNmbrella overflow");
        emit CreateReferrer(_ref.row, _referrer_, _msgSender());
    }

    function withdrawRest(address _token) public onlyOwner{
        IERC20(_token).transfer(owner(),IERC20(_token).balanceOf(address(this)));
    }
    function releaseRefer(address _add) public onlyOwner{
        Referrer storage _ref = _referrers[_add];
        _ref.owner = address(0);
        _ref.row = 0;
   
        uint256 _len = _umbrellas[_ref.owner].length;
        address[] memory _de = new address[](_len);
        
        delete _de[_len -1];
    }
}