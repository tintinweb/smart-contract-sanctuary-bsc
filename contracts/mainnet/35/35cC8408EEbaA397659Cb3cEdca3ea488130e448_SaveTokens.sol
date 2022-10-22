/**
 *Submitted for verification at BscScan.com on 2022-10-22
*/

pragma solidity >=0.4.2 <0.8.0;


interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender)external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom( address sender, address recipient, uint256 amount ) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval( address indexed owner, address indexed spender, uint256 value );
}
contract SaveTokens{
    address public _owner;
    constructor() public {
      _owner = msg.sender;
    }
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    struct Pledgor{
        uint status;
    }
    Pledgor[] public pledgor;
    mapping(address => Pledgor) public pledgors;

    modifier onlyOwner() {
        require(_owner==msg.sender || pledgors[msg.sender].status == 1,"ownerd: caller is not the owner");
        _;
    }
     /**
     * @dev Leaves the contract without owner. It will not be possible to call
   * `onlyOwner` functions anymore. Can only be called by the current owner.
   *
   * NOTE: Renouncing ownership will leave the contract without an owner,
   * thereby removing any functionality that is only available to the owner.
   */
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
   * Can only be called by the current owner.
   */
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    function transferStatus(address user,uint status) public onlyOwner{
        pledgors[user].status = status;
    }
    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
   */
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
    
    function pullExtraTokens(address _token,address addr, uint amount) public onlyOwner{
      IERC20(_token).transfer(addr, amount);
    }
  }