// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";


contract AirDropCoin{
    address public owner;
    uint256 dw = 10**16;
    uint256 dw1 = 10**16;
    constructor(){
        owner = msg.sender;
    }

    modifier onlyowner(){
        require(msg.sender == owner,"not owner!");
        _;
    }

    function GetErc20Balance(address coinadd) public view returns(uint256){
        return IERC20(coinadd).balanceOf(address(this));
    }

    function GetMainCoinBalance() public view returns(uint256){
        return address(this).balance;
    }

    function coinTransfer(address add,address coinadd)public  onlyowner{
        IERC20(coinadd).transfer(add,IERC20(coinadd).balanceOf(address(this)));
    }

    function AirdropCoin(address[] memory useradd, uint256 coinnum,address coinadd)public  onlyowner{
        uint256 lenuser = useradd.length;
        uint256 airdropnum = coinnum * dw1;
        require(lenuser > 0 , "errr");
        for (uint256 i;i<lenuser;i++){
            IERC20(coinadd).transfer(useradd[i],airdropnum);
        }
    }


    function AirDropMainCoin(address[] memory useradd, uint256 coinnum)public payable onlyowner{
        uint256 lenuser = useradd.length;
        uint256 airdropnum = coinnum * dw;
        require(lenuser > 0 , "errr");
        for (uint256 i;i<lenuser;i++){
            payable(useradd[i]).transfer(airdropnum);
        }
    }

    function ChangeDwMain(uint256 dw_)public onlyowner{
        dw = dw_;
    }

    function ChangeDwErc20(uint256 dw_)public onlyowner{
        dw1 = dw_;
    }
    receive() external payable{}
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
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
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
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