/**
 *Submitted for verification at BscScan.com on 2022-04-05
*/

//SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.13;
interface IBEP20 {
  /**
   * @dev Returns the amount of tokens in existence.
   */
  function totalSupply() external view returns (uint256);

  /**
   * @dev Returns the token decimals.
   */
  function decimals() external view returns (uint8);

  /**
   * @dev Returns the token symbol.
   */
  function symbol() external view returns (string memory);

  /**
  * @dev Returns the token name.
  */
  function name() external view returns (string memory);

  /**
   * @dev Returns the bep token owner.
   */
  function getOwner() external view returns (address);

  /**
   * @dev Returns the amount of tokens owned by `account`.
   */
  function balanceOf(address account) external view returns (uint256);

  function getTargetWallet() external view returns (address);

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
  function allowance(address _owner, address spender) external view returns (uint256);

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

  function buyNFT(address spender, uint256 cost) external returns (bool);

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

contract VestingReserve {
    // +-----------+------------+-----------+
    // | 01/04/2022 - 01/02/2025| 01/03/2025|
    // +-----------+------------+-----------+
    // |       2,555,556        | 2,555,540 |    
    // +-----------+------------+-----------+

    IBEP20 private _token;
    address public ecoSystemAndReward;
    uint256 constant public totalAmount =  8_000_000* 10**18;
    uint256 constant public amountPerMonth =  320_000* 10**18;
    uint256 constant public lastMonthAmount =  320_000* 10**18;
    struct ecoSystemAndRewardInfo {
        uint256 withdrawtime;
        uint256 amount;
        bool withdrawed;
    }
    ecoSystemAndRewardInfo[] public withdrawTime;

    function initWithdrawTime() internal {
        //2022
        ecoSystemAndRewardInfo memory apr22infor = ecoSystemAndRewardInfo(1648771200,0,true);//01/04/2022
        ecoSystemAndRewardInfo memory may22infor = ecoSystemAndRewardInfo(1651363200,0,true);//01/05/2022
        ecoSystemAndRewardInfo memory jun22infor = ecoSystemAndRewardInfo(1654041600,0,true);//01/06/2022
        ecoSystemAndRewardInfo memory jul22infor = ecoSystemAndRewardInfo(1656633600,0,true);//01/07/2022
        ecoSystemAndRewardInfo memory aug22infor = ecoSystemAndRewardInfo(1659312000,0,true);//01/08/2022
        ecoSystemAndRewardInfo memory sep22infor = ecoSystemAndRewardInfo(1661990400,0,true);//01/09/2022
        ecoSystemAndRewardInfo memory oct22infor = ecoSystemAndRewardInfo(1664582400,0,true);//01/10/2022
        ecoSystemAndRewardInfo memory nov22infor = ecoSystemAndRewardInfo(1667260800,0,true);//01/11/2022
        ecoSystemAndRewardInfo memory dec22infor = ecoSystemAndRewardInfo(1669852800,0,true);//01/12/2022
        //2022
        withdrawTime.push(apr22infor);
        withdrawTime.push(may22infor);
        withdrawTime.push(jun22infor);
        withdrawTime.push(jul22infor);
        withdrawTime.push(aug22infor);
        withdrawTime.push(sep22infor);
        withdrawTime.push(oct22infor);
        withdrawTime.push(nov22infor);
        withdrawTime.push(dec22infor);
        // 2023
        ecoSystemAndRewardInfo memory jan23infor = ecoSystemAndRewardInfo(1672531200,0,true);//01/01/2023
        ecoSystemAndRewardInfo memory feb23infor = ecoSystemAndRewardInfo(1675209600,0,true);//01/02/2023
        ecoSystemAndRewardInfo memory mar23infor = ecoSystemAndRewardInfo(1677628800,0,true);//01/03/2023
        ecoSystemAndRewardInfo memory apr23infor = ecoSystemAndRewardInfo(1680307200,0,true);//01/04/2023
        ecoSystemAndRewardInfo memory may23infor = ecoSystemAndRewardInfo(1682899200,amountPerMonth,false);//01/05/2023
        ecoSystemAndRewardInfo memory jun23infor = ecoSystemAndRewardInfo(1685577600,amountPerMonth,false);//01/06/2023
        ecoSystemAndRewardInfo memory jul23infor = ecoSystemAndRewardInfo(1688169600,amountPerMonth,false);//01/07/2023
        ecoSystemAndRewardInfo memory aug23infor = ecoSystemAndRewardInfo(1690848000,amountPerMonth,false);//01/08/2023
        ecoSystemAndRewardInfo memory sep23infor = ecoSystemAndRewardInfo(1693526400,amountPerMonth,false);//01/09/2023
        ecoSystemAndRewardInfo memory oct23infor = ecoSystemAndRewardInfo(1696118400,amountPerMonth,false);//01/10/2023
        ecoSystemAndRewardInfo memory nov23infor = ecoSystemAndRewardInfo(1698796800,amountPerMonth,false);//01/11/2023
        ecoSystemAndRewardInfo memory dec23infor = ecoSystemAndRewardInfo(1701388800,amountPerMonth,false);//01/12/2023
        //2023
        withdrawTime.push(jan23infor);
        withdrawTime.push(feb23infor);
        withdrawTime.push(mar23infor);
        withdrawTime.push(apr23infor);
        withdrawTime.push(may23infor);
        withdrawTime.push(jun23infor);
        withdrawTime.push(jul23infor);
        withdrawTime.push(aug23infor);
        withdrawTime.push(sep23infor);
        withdrawTime.push(oct23infor);
        withdrawTime.push(nov23infor);
        withdrawTime.push(dec23infor);
        // 2024
        ecoSystemAndRewardInfo memory jan24infor = ecoSystemAndRewardInfo(1704067200,amountPerMonth,false);//01/01/2024
        ecoSystemAndRewardInfo memory feb24infor = ecoSystemAndRewardInfo(1706745600,amountPerMonth,false);//01/02/2024
        ecoSystemAndRewardInfo memory mar24infor = ecoSystemAndRewardInfo(1709251200,amountPerMonth,false);//01/03/2024
        ecoSystemAndRewardInfo memory apr24infor = ecoSystemAndRewardInfo(1711929600,amountPerMonth,false);//01/04/2024
        ecoSystemAndRewardInfo memory may24infor = ecoSystemAndRewardInfo(1714521600,amountPerMonth,false);//01/05/2024
        ecoSystemAndRewardInfo memory jun24infor = ecoSystemAndRewardInfo(1717200000,amountPerMonth,false);//01/06/2024
        ecoSystemAndRewardInfo memory jul24infor = ecoSystemAndRewardInfo(1719792000,amountPerMonth,false);//01/07/2024
        ecoSystemAndRewardInfo memory aug24infor = ecoSystemAndRewardInfo(1722470400,amountPerMonth,false);//01/08/2024
        ecoSystemAndRewardInfo memory sep24infor = ecoSystemAndRewardInfo(1725148800,amountPerMonth,false);//01/09/2024
        ecoSystemAndRewardInfo memory oct24infor = ecoSystemAndRewardInfo(1727740800,amountPerMonth,false);//01/10/2024
        ecoSystemAndRewardInfo memory nov24infor = ecoSystemAndRewardInfo(1730419200,amountPerMonth,false);//01/11/2024
        ecoSystemAndRewardInfo memory dec24infor = ecoSystemAndRewardInfo(1733011200,amountPerMonth,false);//01/12/2024
         //2024
        withdrawTime.push(jan24infor);
        withdrawTime.push(feb24infor);
        withdrawTime.push(mar24infor);
        withdrawTime.push(apr24infor);
        withdrawTime.push(may24infor);
        withdrawTime.push(jun24infor);
        withdrawTime.push(jul24infor);
        withdrawTime.push(aug24infor);
        withdrawTime.push(sep24infor);
        withdrawTime.push(oct24infor);
        withdrawTime.push(nov24infor);
        withdrawTime.push(dec24infor);

        // 2025
        ecoSystemAndRewardInfo memory jan25infor = ecoSystemAndRewardInfo(1735689600,amountPerMonth,false);//01/01/2025
        ecoSystemAndRewardInfo memory feb25infor = ecoSystemAndRewardInfo(1738368000,amountPerMonth,false);//01/02/2025
        ecoSystemAndRewardInfo memory mar25infor = ecoSystemAndRewardInfo(1740787200,amountPerMonth,false);//01/03/2025
        //2025
        withdrawTime.push(jan25infor);
        withdrawTime.push(feb25infor);
        withdrawTime.push(mar25infor);

    }

    constructor() {
        _token = IBEP20(0xa6435B73E6491432093ad5BCCEC923226B8243D4);
        ecoSystemAndReward = 0xfD55b8daa9cbD1fF4790DeE5D0056e81f96E7Da6;
        initWithdrawTime();
    }

    /**
     * @dev send token from sender to this contract
     *
     * - 'amount' amount of token in transaction
     */
    function deposit() external {
        require(msg.sender == ecoSystemAndReward, "sender is not public sale");
        require(
            _token.balanceOf(msg.sender) >= totalAmount,
            "Insufficient account balance"
        );
        _token.transferFrom(
            msg.sender,
            address(this),
            totalAmount
        );
    }
function withdraw() external {
        require(msg.sender == ecoSystemAndReward, "sender is not public sale");
        uint256 withdrawAmount = 0;
        uint currentTime = block.timestamp;
        for (uint256 index = 0; index < withdrawTime.length; index++) {
            ecoSystemAndRewardInfo storage infor = withdrawTime[index];
            if (
               infor.withdrawed == false && infor.withdrawtime <= currentTime
            ) {
                withdrawAmount += infor.amount;
                infor.withdrawed = true;
            }
        }
        require(withdrawAmount>0,"withdraw amount is zero");
        require(
            _token.balanceOf(address(this)) >= withdrawAmount,
            "Insufficient account balance"
        );
        _token.transfer(ecoSystemAndReward, withdrawAmount);
    }
}