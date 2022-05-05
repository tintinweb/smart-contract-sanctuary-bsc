/**
 *Submitted for verification at BscScan.com on 2022-05-05
*/

// File: https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v3.0.0/contracts/token/ERC20/IERC20.sol

pragma solidity ^0.6.0;

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
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

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

// File: TokenSwap.sol

pragma solidity ^0.6.0;
//SPDX-License-Identifier: MIT

// import 'https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/ERC20.sol';

// import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
// totalSupply()
// balanceOf(account)
// transfer(to, amount)
// allowance(owner, spender)
// approve(spender, amount)
// transferFrom(from, to, amount)

contract TokenSwap {
    IERC20 public exToken; //token PGC ở contact cũ
    IERC20 public newToken; //token PGC ở contact mới
    address public owner;

    constructor(address _exToken, address _newToken) public {
        exToken = IERC20(_exToken); //--> exToken sẽ có các hàm của chuẩn IERC20 
        newToken = IERC20(_newToken);
        owner = msg.sender;
    }

    // function swap(address _receiver, uint amount) external {
    //     // require(msg.sender == owner, 'You are not owner of contract');
    //     //kiểm tra receiver đã approve số lượng token ở contract cũ cho contract swap token này chưa
    //     require(exToken.allowance(_receiver, address(this)) >= amount, 'Approval exToken is not enought');

    //     //kiểm tra người thực thi function (chủ contact này)
    //     require(newToken.allowance(msg.sender, address(this)) >= amount, 'Approval newToken is not enought');

    //     //thỏa các điều kiện, tiến hành chuyển đổi
    //     exToken.transferFrom(_receiver, msg.sender, amount);
    //     newToken.transferFrom(msg.sender, _receiver, amount);
    // }

    //thay đổi thành người dùng tự swap, không còn phải đợi admin thực thi
    function swap(uint amount) external {
        // require(msg.sender == owner, 'You are not owner of contract');
        //kiểm tra người thực thi function đã approve số lượng token ở contract cũ cho contract swap token này chưa
        require(exToken.allowance(msg.sender, address(this)) >= amount, 'Approval exToken is not enought');

        //kiểm tra chủ contact này đã approve số lượng token ở contract mới cho contract swap token này chưa
        require(newToken.allowance(owner, address(this)) >= amount, 'Approval newToken is not enought');

        //thỏa các điều kiện, tiến hành chuyển đổi
        exToken.transferFrom(msg.sender, owner, amount);
        newToken.transferFrom(owner, msg.sender, amount);
    }
}