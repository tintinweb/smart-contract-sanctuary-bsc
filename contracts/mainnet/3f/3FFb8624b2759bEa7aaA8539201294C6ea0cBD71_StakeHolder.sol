/**
 *Submitted for verification at BscScan.com on 2022-08-18
*/

/**
 *Submitted for verification at BscScan.com on 2022-07-21
*/

/**
 * Develop by CPTRedHawk
 * @ Esse contrato Foi desenvolvido por https://t.me/redhawknfts
 * Caso queira ter uma plataforma similar, gentileza chamar no Telegram!
 * SPDX-License-Identifier: MIT
 * Entrega teu caminho ao senhor, e tudo ele o fará! Salmos 37
 */
pragma solidity ^0.8.14;

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

library Math {
    enum Rounding {
        Down, // Toward negative infinity
        Up, // Toward infinity
        Zero // Toward zero
    }

    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? a : b;
    }
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    function average(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b) / 2 can overflow.
        return (a & b) + (a ^ b) / 2;
    }

    function ceilDiv(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b - 1) / b can overflow on addition, so we distribute.
        return a == 0 ? 0 : (a - 1) / b + 1;
    }

    function mulDiv(
        uint256 x,
        uint256 y,
        uint256 denominator
    ) internal pure returns (uint256 result) {
        unchecked {
            // 512-bit multiply [prod1 prod0] = x * y. Compute the product mod 2^256 and mod 2^256 - 1, then use
            // use the Chinese Remainder Theorem to reconstruct the 512 bit result. The result is stored in two 256
            // variables such that product = prod1 * 2^256 + prod0.
            uint256 prod0; // Least significant 256 bits of the product
            uint256 prod1; // Most significant 256 bits of the product
            assembly {
                let mm := mulmod(x, y, not(0))
                prod0 := mul(x, y)
                prod1 := sub(sub(mm, prod0), lt(mm, prod0))
            }

            // Handle non-overflow cases, 256 by 256 division.
            if (prod1 == 0) {
                return prod0 / denominator;
            }

            // Make sure the result is less than 2^256. Also prevents denominator == 0.
            require(denominator > prod1);

            ///////////////////////////////////////////////
            // 512 by 256 division.
            ///////////////////////////////////////////////

            // Make division exact by subtracting the remainder from [prod1 prod0].
            uint256 remainder;
            assembly {
                // Compute remainder using mulmod.
                remainder := mulmod(x, y, denominator)

                // Subtract 256 bit number from 512 bit number.
                prod1 := sub(prod1, gt(remainder, prod0))
                prod0 := sub(prod0, remainder)
            }

            // Factor powers of two out of denominator and compute largest power of two divisor of denominator. Always >= 1.
            // See https://cs.stackexchange.com/q/138556/92363.

            // Does not overflow because the denominator cannot be zero at this stage in the function.
            uint256 twos = denominator & (~denominator + 1);
            assembly {
                // Divide denominator by twos.
                denominator := div(denominator, twos)

                // Divide [prod1 prod0] by twos.
                prod0 := div(prod0, twos)

                // Flip twos such that it is 2^256 / twos. If twos is zero, then it becomes one.
                twos := add(div(sub(0, twos), twos), 1)
            }

            // Shift in bits from prod1 into prod0.
            prod0 |= prod1 * twos;

            // Invert denominator mod 2^256. Now that denominator is an odd number, it has an inverse modulo 2^256 such
            // that denominator * inv = 1 mod 2^256. Compute the inverse by starting with a seed that is correct for
            // four bits. That is, denominator * inv = 1 mod 2^4.
            uint256 inverse = (3 * denominator) ^ 2;

            // Use the Newton-Raphson iteration to improve the precision. Thanks to Hensel's lifting lemma, this also works
            // in modular arithmetic, doubling the correct bits in each step.
            inverse *= 2 - denominator * inverse; // inverse mod 2^8
            inverse *= 2 - denominator * inverse; // inverse mod 2^16
            inverse *= 2 - denominator * inverse; // inverse mod 2^32
            inverse *= 2 - denominator * inverse; // inverse mod 2^64
            inverse *= 2 - denominator * inverse; // inverse mod 2^128
            inverse *= 2 - denominator * inverse; // inverse mod 2^256

            // Because the division is now exact we can divide by multiplying with the modular inverse of denominator.
            // This will give us the correct result modulo 2^256. Since the preconditions guarantee that the outcome is
            // less than 2^256, this is the final result. We don't need to compute the high bits of the result and prod1
            // is no longer required.
            result = prod0 * inverse;
            return result;
        }
    }

    function mulDiv(
        uint256 x,
        uint256 y,
        uint256 denominator,
        Rounding rounding
    ) internal pure returns (uint256) {
        uint256 result = mulDiv(x, y, denominator);
        if (rounding == Rounding.Up && mulmod(x, y, denominator) > 0) {
            result += 1;
        }
        return result;
    }

    function sqrt(uint256 a) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 result = 1;
        uint256 x = a;
        if (x >> 128 > 0) {
            x >>= 128;
            result <<= 64;
        }
        if (x >> 64 > 0) {
            x >>= 64;
            result <<= 32;
        }
        if (x >> 32 > 0) {
            x >>= 32;
            result <<= 16;
        }
        if (x >> 16 > 0) {
            x >>= 16;
            result <<= 8;
        }
        if (x >> 8 > 0) {
            x >>= 8;
            result <<= 4;
        }
        if (x >> 4 > 0) {
            x >>= 4;
            result <<= 2;
        }
        if (x >> 2 > 0) {
            result <<= 1;
        }

        unchecked {
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            return min(result, a / result);
        }
    }

    function sqrt(uint256 a, Rounding rounding) internal pure returns (uint256) {
        uint256 result = sqrt(a);
        if (rounding == Rounding.Up && result * result < a) {
            result += 1;
        }
        return result;
    }
}


library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }


    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }


    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }


    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }


    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }


    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }


    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }


    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }


    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }


    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}

interface IBEP20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function decimals() external view returns (uint256);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract StakeHolder is Ownable {
    /*
    * @ Atenção a partir da versão 0.8.0 Solidity não é mais preciso utilizar SafeMath ou Math
    * Mas por medidas de precaução recomendo manter o uso do SafeMath
    */
    using SafeMath for uint256;
    using Math for uint256;
    /*
    ---------------------------------
    -           Adress              -
    ---------------------------------
    */
    IBEP20 public stakingToken;
    IBEP20 public stakingReward;
    address public walletMarketing;
    /*
    ---------------------------------
    -           Mapping             -
    ---------------------------------
    */
    mapping(address => uint256) public balanceUser;
    mapping(address => uint256) public userRewardPerTokenPaid;
    mapping(address => uint256) public rewards;
    /*
    ---------------------------------
    -           Number              -
    ---------------------------------
    */
    uint256 public balanceContract;
    uint256 public totalSupply;
    uint256 public periodFinish;
    uint256 public rewardPerTokenStored;
    uint256 public rewardRate;
    uint256 public lastUpdateTime;
    uint256 public rewardsDuration;
    uint256 public stakingTokensDecimalRate = 10**9;
    uint256 public valueTax = 1400000000000000;
    /*
    ---------------------------------
    -           Modifier            -
    ---------------------------------
    */
    modifier updateReward(address account) {
        rewardPerTokenStored = rewardPerToken();
        lastUpdateTime = lastTimeRewardApplicable();
        if (account != address(0)) {
            rewards[account] = earned(account);
            userRewardPerTokenPaid[account] = rewardPerTokenStored;
        }
        _;
    }
    /*
    ---------------------------------
    -           Constructor         -
    ---------------------------------
    */
    constructor ( 
        address _stakingToken,
        address _rewardsToken,
        uint256 _rewardsDuration,
        address _marketing
    )   {
        stakingToken = IBEP20(_stakingToken);
        stakingReward = IBEP20(_rewardsToken);
        rewardsDuration = _rewardsDuration;
        walletMarketing = _marketing;
    }
    // Retira os Fundos em BNB
    function transferFundsBNB() private {
        require(walletMarketing != address(0), "Cannot withdraw the ETH balance to the zero address");
        // Transfere BNB para o Owner
        payable(walletMarketing).transfer(msg.value);
    }
    /*
    ---------------------------------
    -       Public/External         -
    ---------------------------------
    */
    // Inicia o Stake User
    function createStakeOne(uint256 amount) external payable updateReward(_msgSender()) {
        IBEP20(stakingToken).transferFrom(_msgSender(), address(this), amount);
        require(msg.value == valueTax, "HSC, preco de taxa precisa ser definido");
        transferFundsBNB();
        balanceUser[_msgSender()] += amount;
        totalSupply += amount;
    }
    // Remove os Tokens Aportados
    function removeMyStake() external payable updateReward(_msgSender()) {
        uint256 amount = balanceUser[_msgSender()];
        require(amount > 0, "HSC Voce nao tem saldo em Stake");
        balanceUser[_msgSender()] = 0;
        totalSupply -= amount;
        uint256 reward = rewards[_msgSender()];
        require(msg.value == valueTax, "HSC, preco de taxa precisa ser definido");
        transferFundsBNB();
        if(reward > 0 ) {
            rewards[_msgSender()] = 0;
            IBEP20(stakingReward).transfer(_msgSender(), reward);
            IBEP20(stakingToken).transfer(_msgSender(), amount);
            reward = 0;
            amount = 0;
        }
        else {
            IBEP20(stakingToken).transfer(_msgSender(), amount);
            amount = 0;
        }
    }
    // Retira recompensas
    function getMyRewards() external payable updateReward(_msgSender()) {
        uint256 reward = rewards[_msgSender()];
        require(msg.value == valueTax, "HSC, preco de taxa precisa ser definido");
        if(reward > 0 ) {
            transferFundsBNB();
            rewards[_msgSender()] = 0;
             IBEP20(stakingReward).transfer(_msgSender(), reward);
            reward = 0;
        }
        else {
            reward = 0;
            require(reward > 0, "HSC: Saldo de recompensa nao pode ser Zero");
        }
    }
    // Ajusta os Decimais de Recompensa
    function setDecimalReward(uint256 _decimalRewards) external onlyOwner {
        stakingTokensDecimalRate = 10**_decimalRewards;
    }
    // Define Tax
    function setPercentTax(uint256 _valueTax) external onlyOwner {
        valueTax = _valueTax;
    }
    // Define carteira do Marketing
    function setWalletMarketing(address _walletMarketing) external onlyOwner {
        walletMarketing = _walletMarketing;
    }
    // Ajusta Duração da Pool
    function poolDuration(uint256 _rewardsDuration) external onlyOwner {
        rewardsDuration = _rewardsDuration;
    }
    // Owner Inicia o Stake
    function initRewards(uint256 amount) external onlyOwner updateReward(address(0)){
        rewardRate = amount.div(rewardsDuration);
        periodFinish = block.timestamp.add(rewardsDuration);
        lastUpdateTime = block.timestamp;
    }
    // Adiciona Liquidez
    function addLiquidityRewards(uint256 amount) external onlyOwner  {
        IBEP20(stakingReward).transferFrom(_msgSender(), address(this), amount);
        balanceContract += amount;
    }
    // Remove Liquidez Recompensa
    function removeLiquityRewards() external onlyOwner {
        uint256 amount = IBEP20(stakingReward).balanceOf(address(this));
        balanceContract = 0;
        IBEP20(stakingReward).transfer(_msgSender(), amount);
        amount = 0;
    }
    // Remove todos os Tokens de Usuarios do Contrato
    function removeStakeUser() external onlyOwner {
        uint256 amount = totalSupply;
        totalSupply = 0;
        IBEP20(stakingToken).transfer(_msgSender(), amount);
        amount = 0;
    }
    // Calcula os Ganhos
    function earned(address account) public view returns (uint256) {
            uint256 earn =             
                balanceUser[account]
                .mul(rewardPerToken().sub(userRewardPerTokenPaid[account]))
                .div(stakingTokensDecimalRate)
                .add(rewards[account]);
            return   earn.div(stakingTokensDecimalRate);

    }
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }
    function lastTimeRewardApplicable() public view returns (uint256) {
        return min(block.timestamp, periodFinish);
    }
    function getRewardForDuration() external view returns (uint256) {
        return rewardRate.mul(rewardsDuration);
    }
    function rewardPerToken() public view returns(uint256) {
        if (totalSupply == 0) {
            return rewardPerTokenStored;
        }
        else {
            return rewardPerTokenStored.add(
                lastTimeRewardApplicable()
                .sub(lastUpdateTime)
                .mul(rewardRate)
                .mul(stakingTokensDecimalRate)
                .div(totalSupply)
            );
        }
    }

}