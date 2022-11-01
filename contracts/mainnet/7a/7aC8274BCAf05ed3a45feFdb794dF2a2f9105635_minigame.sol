/**
 *Submitted for verification at BscScan.com on 2022-11-01
*/

/**
 *Submitted for verification at BscScan.com on 2022-10-22
*/

// SPDX-License-Identifier: MIT
pragma solidity >=0.6.0 <0.9.0;



interface IBEP20 {
  /**
   * @dev Returns the amount of tokens in existence.
   */
  function totalSupply() external view returns (uint256);

  /**
   * @dev Returns the amount of tokens owned by `account`.
   */
  function balanceOf(address account) external view returns (uint256);

  /**
   * @dev Moves `amount` tokens from the caller's account to `recipient`.
   *
   * Returns a boolean value indicating whether the operation succeeded.
   *
   * Emits a {Transfer} event.
   */
  function transfer(address recipient, uint256 amount) external returns (bool);

  /**
   * @dev Returns the remaining number of tokens that `spender` will be
   * allowed to spend on behalf of `owner` through {transferFrom}. This is
   * zero by default.
   *
   * This value changes when {approve} or {transferFrom} are called.
   */
  function allowance(address owner, address spender) external view returns (uint256);

  /**
   * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
   *
   * Returns a boolean value indicating whether the operation succeeded.
   *
   * IMPORTANT: Beware that changing an allowance with this method brings the risk
   * that someone may use both the old and the new allowance by unfortunate
   * transaction ordering. One possible solution to mitigate this race
   * condition is to first reduce the spender's allowance to 0 and set the
   *
   * Emits an {Approval} event.
   */
  function approve(address spender, uint256 amount) external returns (bool);

  /**
   * @dev Moves `amount` tokens from `sender` to `recipient` using the
   * allowance mechanism. `amount` is then deducted from the caller's
   * allowance.
   *
   * Returns a boolean value indicating whether the operation succeeded.
   *
   * Emits a {Transfer} event.
   */
  function transferFrom(
    address sender,
    address recipient,
    uint256 amount
  ) external returns (bool);

  /**
   * @dev Emitted when `value` tokens are moved from one account (`from`) to
   * another (`to`).
   *
   * Note that `value` may be zero.
   */
  event Transfer(address indexed from, address indexed to, uint256 value);

  /**
   * @dev Emitted when the allowance of a `spender` for an `owner` is set by
   * a call to {approve}. `value` is the new allowance.
   */
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract minigame {

    constructor() payable{
        _owner = msg.sender;
    }

    struct addressplace {
        uint256 select;
        uint256 amount;
        uint256 result;
    }
    struct State{
        uint256 totalRock;
        uint256 totalPapar;
        uint256 totoalScissors;
        uint256 result;
        uint256 endtime;
    }
    event onPlace(address _address, uint256 select, uint256 amount, uint256 result);
    address public SDCContract = 0xfC28d2a0D14ef2819260F168cf58C90e6225a247;
    State public state;

    mapping(address => addressplace) public mapAddress;

    function place(uint256 select, uint256 amount)  public {
        require(IBEP20(SDCContract).allowance(msg.sender,address(this)) >= amount,"The token allowed is not enough. You need approve more token");
        require(IBEP20(SDCContract).balanceOf(msg.sender) >= amount,"The token is not enough.");
        require(select == 3 || select == 1 || select == 2, "select not valid");
        
        if (select == 1)
            state.totalRock += amount;
        if (select == 2)
            state.totalPapar += amount;
        if (select == 3)
            state.totoalScissors += amount;
        
        IBEP20(SDCContract).transferFrom(msg.sender, address(this), amount);
        uint256 result = random(1, 4);
        if (result == select){
            IBEP20(SDCContract).transfer(msg.sender, amount + amount *95/100);
        }

        addressplace memory x;
        x.select = select;
        x.amount = amount;
        x.result = result;
        mapAddress[msg.sender] = x;
        emit onPlace(msg.sender, select, amount, result);
    }

    function withdraw(uint256 amount) external onlyOwner {

        IBEP20(SDCContract).transfer(_owner, amount);
       
    }

    receive() external payable {}


    function random(
        uint256 from,
        uint256 to
    ) private view returns (uint256) {
        uint256 seed = uint256(
            keccak256(
                abi.encodePacked(
                    block.timestamp + block.number 
                )
            )
        );
        return (seed % (to - from)) + from;
    }
    
    address private _owner;
    modifier onlyOwner() { require(_owner == msg.sender, "Caller =/= owner."); _; }
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function transferOwner(address newOwner) external onlyOwner {
        require(newOwner != address(0), "Call renounceOwnership to transfer owner to the zero address.");
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }

    function renounceOwnership() external onlyOwner {
        address oldOwner = _owner;
        _owner = address(0);
        emit OwnershipTransferred(oldOwner, address(0));
    }
}