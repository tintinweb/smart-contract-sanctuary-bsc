/*
    PigBnb Miner presale - BSC Miner Presale
    Developed by Kraitor <TG: kraitordev>
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "./BasicLibraries/SafeMath.sol";
import "./BasicLibraries/Auth.sol";

contract MinerPresale is Auth {
    using SafeMath for uint256;

    uint256 public totalInvested; //Total BNB invested
    uint256 public softCap = 100 * 10**18;
    uint256 public hardCap = 150 * 10**18;

    address public minerCA = address(0); //Miner CA, we need it because only miner can take the airdrop and mark an address as airdropped
    address public lotCA = address(0);
    uint256 nPresalers; //Total investors
    mapping(address => uint256) public addressInvestment; //Investment per address
    mapping(address => bool) public airdropped; //Address that have been already airdropped
    uint256 public pigPerBnbRate = 10000; //Airdrop rate
    bool public opened;

    uint256 ownerTax = 5;
    uint256 lotTax = 5;

    //CONFIG/////////////////////////
    function setMinerCA(address _minerCA) external authorized { minerCA = _minerCA; }

    function setLotCA(address _lotCA) external authorized { lotCA = _lotCA; }

    function setTaxes(uint256 _lotTax, uint256 _ownerTax) external authorized {
        require(_lotTax.add(_ownerTax) < 100, 'Invalid tax');
        lotTax = _lotTax; 
        ownerTax = _ownerTax; 
    }

    function openClosePresale(bool _openClosePresale) external authorized { opened = _openClosePresale; }

    //Set presale rate in pigs/bnb
    function setPresaleRate(uint256 _ratePigsPerBNB) external authorized { pigPerBnbRate = _ratePigsPerBNB; }

    //Set soft and harcap without decimals
    function setSoftHardCap(uint256 _softcapBNBnoDec, uint256 _hardcapBNBnoDec) external authorized {
        softCap = _softcapBNBnoDec * 10 ** 18;
        hardCap = _hardcapBNBnoDec * 10 ** 18;
    }
    /////////////////////////////////


    //How much pigs minerCA will airdrop to that address
    function pigsToAirdrop(address adr) external view returns (uint256) {
        require(airdropped[adr] == false, 'Address already airdropped');
        require(addressInvestment[adr] > 0, 'Address did not invest in presale');
        return addressInvestment[adr].mul(pigPerBnbRate).div(10**18);
    }

    //We mark the address as airdropped so wont be airdropped two times
    //Only miner CA can do this
    function addressAirdropped(address adr) external {
        require(msg.sender == minerCA, 'Only miner can do this');
        require(airdropped[adr] == false, 'Address already airdropped');
        airdropped[adr] = true;
    }

    function deposit() external payable{
        require(opened, 'Presale still not opened');
        require(msg.value > 0, 'You need to pay BNB to invest');
        require(hardCapReached() == false, 'Hardcap reached');     
        require(msg.value <= bnbLeftToHardcap(), 'Amount invalid');   

        if(addressInvestment[msg.sender] == 0){
            nPresalers++;
        }
        totalInvested += msg.value;
        addressInvestment[msg.sender] = addressInvestment[msg.sender].add(msg.value);
    }

    function bnbLeftToHardcap() public view returns(uint256) { 
        if(totalInvested > hardCap) return 0;
        return hardCap.sub(totalInvested); 
    }

    function softCapReached() public view returns(bool){ return totalInvested >= softCap; }

    function hardCapReached() public view returns(bool){ return totalInvested >= hardCap; }

    //Owner can withdraw the BNB invested anytime
    function withdrawInvestments() external payable authorized {
        uint256 balanceWDW = address(this).balance;

        if(ownerTax > 0){ payable(owner).transfer(balanceWDW.mul(ownerTax).div(100)); }
        if(lotTax > 0){ payable(lotCA).transfer(balanceWDW.mul(lotTax).div(100)); }
        payable(minerCA).transfer(balanceWDW.mul(uint256(100).sub(lotTax).sub(ownerTax)).div(100));
    }

    constructor(address _minerCA, address _lotCA) Auth(msg.sender) { minerCA = _minerCA; lotCA = _lotCA; }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

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

    /**
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
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

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator.
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {trySub}.
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
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

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
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

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting with custom message when dividing by zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryMod}.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
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

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

abstract contract Auth {
    address internal owner;
    mapping (address => bool) internal authorizations;

    constructor(address _owner) {
        owner = _owner;
        authorizations[_owner] = true;
    }

    /**
     * Function modifier to require caller to be contract owner
     */
    modifier onlyOwner() {
        require(isOwner(msg.sender), "!OWNER"); _;
    }

    /**
     * Function modifier to require caller to be authorized
     */
    modifier authorized() {
        require(isAuthorized(msg.sender), "!AUTHORIZED"); _;
    }

    /**
     * Authorize address. Owner only
     */
    function authorize(address adr) public onlyOwner {
        authorizations[adr] = true;
    }

    /**
     * Remove address' authorization. Owner only
     */
    function unauthorize(address adr) public onlyOwner {
        authorizations[adr] = false;
    }

    /**
     * Check if address is owner
     */
    function isOwner(address account) public view returns (bool) {
        return account == owner;
    }

    /**
     * Return address' authorization status
     */
    function isAuthorized(address adr) public view returns (bool) {
        return authorizations[adr];
    }

    /**
     * Transfer ownership to new address. Caller must be owner. Leaves old owner authorized
     */
    function transferOwnership(address payable adr) public onlyOwner {
        owner = adr;
        authorizations[adr] = true;
        emit OwnershipTransferred(adr);
    }

    event OwnershipTransferred(address owner);
}