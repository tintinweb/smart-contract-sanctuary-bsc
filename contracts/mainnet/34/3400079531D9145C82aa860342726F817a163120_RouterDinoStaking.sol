// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./interfaces/IERC20.sol";
import "./interfaces/IWETH.sol";
import "./interfaces/IDinostaking.sol";
import "./libraries/SafeMath.sol";
import "./libraries/Context.sol";
import "./libraries/Auth.sol";
contract RouterDinoStaking is Context, Auth {
    using SafeMath for uint256;

    address public wbnbAddress;

    address public manualStakingAddress;
    address public autoStakingAddress;
    address public tokenAddress;

    uint256 public percentDenominator = 10000;
    uint256 public percentAutoStaking = 5000;
    uint256 public percentManualStaking = 5000;

    event Deposit(address account, uint256 amount);
    event Stake(address account, uint256 amount);
    event UnStake(address account, uint256 amount);

    constructor(address _tokenAddress,address _wbnbAddress) Auth(msg.sender) {
        tokenAddress = _tokenAddress;
        wbnbAddress = _wbnbAddress;
    }

    receive() external payable {}

    function deposit(uint256 loop) public payable {
        if(autoStakingAddress != address(0) && manualStakingAddress != address(0)){
            uint256 supplyAuto = IERC20(autoStakingAddress).totalSupply();
            uint256 supplyManual = IERC20(manualStakingAddress).totalSupply();
            uint256 amountDeposit = msg.value;
            if(supplyAuto > 0) {   
                // uint256 amountAuto = (supplyAuto.mul(percentDenominator).div(supplyAuto.add(supplyManual))).mul(msg.value).div(percentDenominator);
                uint256 amountAuto = amountDeposit.mul(percentAutoStaking).div(percentDenominator);
                IDinostaking(autoStakingAddress).deposit{value:amountAuto}(loop);
            }
            if(supplyManual > 0){
                // uint256 amountManual = (supplyManual.mul(percentDenominator).div(supplyAuto.add(supplyManual))).mul(msg.value).div(percentDenominator);
                uint256 amountManual = amountDeposit.mul(percentManualStaking).div(percentDenominator);
                IDinostaking(manualStakingAddress).deposit{value:amountManual}(loop);
            }
        }
    }

    function setPercentDistribution(uint256 percentAuto, uint256 percentManual) public onlyOwner{
        percentAutoStaking = percentAuto;
        percentManual = percentManual;
        require(percentManual+percentAuto == percentDenominator,"Should be 10000");
    }

    function depositWithOther(address token, uint256 amount) external {

    }

    function stake(address stakingAddress, address account, uint256 amount) external {
        IERC20(tokenAddress).transferFrom(_msgSender(),address(this),amount);
        IERC20(tokenAddress).approve(stakingAddress,amount);
        IDinostaking(stakingAddress).stake(account,amount);
    }

    function unstake(address stakingAddress, address account,uint256 amount) external {
        IERC20(stakingAddress).transferFrom(_msgSender(),address(this),amount);
        IDinostaking(stakingAddress).unstake(account,amount);
    }


    function claimToEth(address stakingAddress, address account) external {
        IDinostaking(stakingAddress).claimToEth(account);
    }

    function claimToOther(address stakingAddress, address account, address targetToken) external {
        // tobe update
        IDinostaking(stakingAddress).claimToOther(account,targetToken);
    }

    function setWbnbAddress(address _wbnbAddress) external onlyOwner {
        wbnbAddress = _wbnbAddress;
    }

    function setStakingAddress(address _manual, address _auto) external onlyOwner {
        manualStakingAddress = _manual;
        autoStakingAddress = _auto;
    }

    function claimWeth(address to, uint256 amount) external onlyOwner {
        payable(to).transfer(amount);
    }

    function claimFromContract(address _tokenAddress, address to, uint256 amount) external onlyOwner {
        IERC20(_tokenAddress).transfer(to, amount);
    }

}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function decimals() external view returns (uint8);

    function symbol() external view returns (string memory);

    function name() external view returns (string memory);

    function getOwner() external view returns (address);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function allowance(address _owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IWETH {
    function deposit() external payable;
    function transfer(address to, uint value) external returns (bool);
    function withdraw(uint) external;
    function balanceOf(address account) external view returns (uint256);
    function approve(address guy, uint wad) external returns (bool);
    function transferFrom(address src, address dst, uint256 wad) external returns (bool);
    function allowance(address _owner, address spender)
        external
        view
        returns (uint256);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IDinostaking {
    function deposit(uint256 loop) external payable;

    function depositWithOther(address token, uint256 amount) external;

    function setAutoStaking() external;

    function stake(address account, uint256 amount) external;

    function unstake(address account, uint256 amount) external;

    function claimToEth(address account) external;

    function claimToOther(address account, address targetToken) external;

    function batchRestake() external;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library SafeMath {
    function tryAdd(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    function trySub(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    function tryMul(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
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

    function tryDiv(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    function tryMod(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
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

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

abstract contract Auth {
    address internal owner;
    mapping(address => bool) internal authorizations;

    constructor(address _owner) {
        owner = _owner;
        authorizations[_owner] = true;
    }

    modifier onlyOwner() {
        require(isOwner(msg.sender), "BabyToken: !OWNER");
        _;
    }

    modifier authorized() {
        require(isAuthorized(msg.sender), "BabyToken: !AUTHORIZED");
        _;
    }

    function authorize(address adr) public onlyOwner {
        authorizations[adr] = true;
    }

    function unauthorize(address adr) public onlyOwner {
        authorizations[adr] = false;
    }

    function isOwner(address account) public view returns (bool) {
        return account == owner;
    }

    function isAuthorized(address adr) public view returns (bool) {
        return authorizations[adr];
    }

    function transferOwnership(address payable adr) public onlyOwner {
        owner = adr;
        authorizations[adr] = true;
        emit OwnershipTransferred(adr);
    }

    function _getOwner() public view returns (address) {
        return owner;
    }

    event OwnershipTransferred(address owner);
}