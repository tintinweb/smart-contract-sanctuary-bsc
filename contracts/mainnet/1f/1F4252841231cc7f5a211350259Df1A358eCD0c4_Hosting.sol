//SPDX-License-Identifier: MIT
pragma solidity 0.8.14;

import "./IERC20.sol";
import "./Ownable.sol";
import "./IUniswapV2Router02.sol";

contract Hosting is Ownable {

    address public constant WETH = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    uint256 public constant month = 864000;

    address public defaultPayToken;

    struct Project {
        uint32 id;
        string identifier;
        uint256 amountPaid;
        uint256 amountPerBlock;
        uint256 lastPaid;
        uint256 tolerance;
        address payToken;
    }
    mapping ( uint32 => Project ) public projects;
    mapping ( string => uint32 ) public projectByIdentifier;

    uint32 public projectNonce;

    address public paymentRecipient;

    constructor(address defaultPayToken_, address recipient_) {
        defaultPayToken = defaultPayToken_;
        paymentRecipient = recipient_;
    }

    function setPayRecipient(address newRecipient) external onlyOwner {
        require(
            newRecipient != address(0),
            'Zero Address'
        );
        paymentRecipient = newRecipient;
    }

    function setDefaultPayToken(address newToken) external onlyOwner {
        defaultPayToken = newToken;
    }

    function resetLastPaidTime(uint32 id, uint256 decrement) external onlyOwner {
        projects[id].lastPaid = block.number - decrement;
    }

    function addProject(string calldata identifier_, uint256 amountMonthly, uint256 tolerance_) external onlyOwner {
        projects[projectNonce].amountPerBlock = amountMonthly / month;
        projects[projectNonce].lastPaid = block.number;
        projects[projectNonce].identifier = identifier_;
        projects[projectNonce].tolerance = tolerance_;
        projects[projectNonce].payToken = defaultPayToken;
        require(
            projectByIdentifier[identifier_] == 0 || projectNonce == 0,
            'Identifier Already Exists'
        );
        projectByIdentifier[identifier_] = projectNonce;
        projectNonce++;
    }

    function setAmountPerMonth(uint32 id, uint256 amountPerMonth_) external onlyOwner {
        projects[id].amountPerBlock = amountPerMonth_ / month;
    }

    function setIdentifier(uint32 id, string calldata identifier_) external onlyOwner {
        require(
            projectByIdentifier[identifier_] == 0,
            'Identifier Already Exists'
        );
        delete projectByIdentifier[projects[id].identifier];
        projectByIdentifier[identifier_] = id;
        projects[id].identifier = identifier_;
    }

    function setTolerance(uint32 id, uint256 tolerance_) external onlyOwner {
        projects[id].tolerance = tolerance_;
    }

    function setPayToken(uint32 id, address newToken) external onlyOwner {
        projects[id].payToken = newToken;
    }



    function convertToPayToken(uint32 id, uint minOut) external payable {
        _convert(projects[id].payToken, address(this).balance, minOut);
    }

    function convertToToken(address token, uint minOut) external payable {
        _convert(token, address(this).balance, minOut);
    }

    function payBill(uint32 id, uint256 additional) external {
        address token = projects[id].payToken;
        require(
            token != WETH,
            'Pay With payBillETH'
        );
        uint owed = amountOwed(id);
        require(owed > 0, 'Zero Owed');
        uint amountToTransfer = additional + owed;

        require(
            IERC20(token).allowance(msg.sender, address(this)) >= amountToTransfer,
            'Insufficient Allowance'
        );
        require(
            IERC20(token).transferFrom(
                msg.sender,
                paymentRecipient,
                amountToTransfer
            ),
            'Failure Transfer From'
        );

        projects[id].lastPaid = block.number + ( additional / projects[id].amountPerBlock );
        unchecked {
            projects[id].amountPaid += amountToTransfer;
        }
    }

    function payBillETH(uint32 id) external payable {
        require(
            projects[id].payToken == WETH,
            'Pay With payBill'
        );

        uint owed = amountOwed(id);
        require(owed > 0, 'Zero Owed');
        require(msg.value >= owed, 'Insufficient Owed');
        uint256 additional = msg.value - owed;

        (bool s,) = payable(paymentRecipient).call{value: address(this).balance}("");
        require(s, 'Failure On ETH Transfer');

        projects[id].lastPaid = block.number + ( additional / projects[id].amountPerBlock);
        unchecked {
            projects[id].amountPaid += msg.value;
        }
    }


    function _convert(address token, uint amount, uint minOut) internal {
        IUniswapV2Router02 router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        address[] memory path = new address[](2);
        path[0] = router.WETH();
        path[1] = token;
        router.swapExactETHForTokensSupportingFeeOnTransferTokens{value: amount}(
            minOut, path, msg.sender, block.timestamp + 10000
        );
        delete path;
    }




    function fetchAllDetails() external view returns (Project[] memory allProjects) {
        allProjects = new Project[](projectNonce);
        for (uint32 i = 0; i < projectNonce; i++) {
            allProjects[i] = projects[i];
        }
    }

    function fetchAllPayTokens() external view returns (address[] memory tokens, string[] memory symbols, uint8[] memory decimals) {
        tokens = new address[](projectNonce);
        symbols = new string[](projectNonce);
        decimals = new uint8[](projectNonce);
        for (uint32 i = 0; i < projectNonce; i++) {
            address token_ = projects[i].payToken;
            tokens[i] = token_;
            symbols[i] = IERC20(token_).symbol();
            decimals[i] = IERC20(token_).decimals();
        }
    }

    function fetchAllDetailsAndPayTokens() external view returns (Project[] memory allProjects, address[] memory tokens, string[] memory symbols, uint8[] memory decimals) {
        allProjects = new Project[](projectNonce);
        tokens = new address[](projectNonce);
        symbols = new string[](projectNonce);
        decimals = new uint8[](projectNonce);
        for (uint32 i = 0; i < projectNonce; i++) {
            address token_ = projects[i].payToken;
            allProjects[i] = projects[i];
            tokens[i] = token_;
            symbols[i] = IERC20(token_).symbol();
            decimals[i] = IERC20(token_).decimals();
        }
    }

    function totalPaid() external view returns (uint256 total) {
        for (uint32 i = 0; i < projectNonce; i++) {
            total += projects[i].amountPaid;
        }
    }

    function totalOwed() external view returns (uint256 total) {
        for (uint32 i = 0; i < projectNonce; i++) {
            total += amountOwed(i);
        }
    }

    function fetchAllOwed() external view returns (uint256[] memory) {
        uint256[] memory allOwed = new uint256[](projectNonce);
        for (uint32 i = 0; i < projectNonce; i++) {
            allOwed[i] = amountOwed(i);
        }
        return allOwed;
    }

    function fetchAllOwedAndTolerance() external view returns (uint256[] memory, uint256[] memory) {
        uint256[] memory allOwed = new uint256[](projectNonce);
        uint256[] memory allTolerances = new uint256[](projectNonce);
        for (uint32 i = 0; i < projectNonce; i++) {
            allOwed[i] = amountOwed(i);
            allTolerances[i] = projects[i].tolerance;
        }
        return (allOwed, allTolerances);
    }

    function fetchAllOwedAndToleranceAndTimePassed() external view returns (uint256[] memory, uint256[] memory, int256[] memory) {
        uint256[] memory allOwed = new uint256[](projectNonce);
        uint256[] memory allTolerances = new uint256[](projectNonce);
        int256[] memory timesPassed = new int256[](projectNonce);
        for (uint32 i = 0; i < projectNonce; i++) {
            allOwed[i] = amountOwed(i);
            allTolerances[i] = projects[i].tolerance;
            timesPassed[i] = timePassed(i);
        }
        return (allOwed, allTolerances, timesPassed);
    }

    function fetchAllShouldDisplaySites() external view returns (bool[] memory) {
        bool[] memory shouldDisplay = new bool[](projectNonce);
        for (uint32 i = 0; i < projectNonce; i++) {
            shouldDisplay[i] = shouldDisplaySite(i);
        }
        return shouldDisplay;
    }

    function fetchAllShouldDisplaySitesAndProjectIdentifiers() external view returns (bool[] memory, string[] memory) {
        bool[] memory shouldDisplay = new bool[](projectNonce);
        string[] memory identifiers = new string[](projectNonce);
        for (uint32 i = 0; i < projectNonce; i++) {
            shouldDisplay[i] = shouldDisplaySite(i);
            identifiers[i] = projects[i].identifier;
        }
        return (shouldDisplay, identifiers);
    }

    function amountOwed(uint32 id) public view returns (uint256) {

        uint last = projects[id].lastPaid;
        uint cost = projects[id].amountPerBlock;
        if (last == 0 || cost == 0) {
            return 0;
        }

        uint tPassed = last < block.number ? block.number - last : 0;
        return tPassed * cost;
    }

    function timePassed(uint32 id) public view returns (int256) {
        uint last = projects[id].lastPaid;
        int tPassed;
        unchecked {
            tPassed = int256(block.number) - int256(last);
        }
        return tPassed;
    }

    function fetchTimePassed() external view returns (int256[] memory) {
        int256[] memory timesPassed = new int256[](projectNonce);
        for (uint32 i = 0; i < projectNonce; i++) {
            timesPassed[i] = timePassed(i);
        }
        return timesPassed;
    }

    function shouldDisplaySite(uint32 id) public view returns (bool) {
        if (id < projectNonce || projects[id].tolerance == 0) {
            return true;
        }
        return projects[id].tolerance >= amountOwed(id);
    }
}