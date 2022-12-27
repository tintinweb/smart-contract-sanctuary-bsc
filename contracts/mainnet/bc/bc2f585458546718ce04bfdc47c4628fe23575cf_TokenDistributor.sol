// SPDX-License-Identifier: MIT

pragma solidity ^0.8.10;

import "./SafeMath.sol";
import "./Address.sol";
import "./Ownable.sol";
import "./IERC20Metadata.sol";

/*
 * @title TokenDistributor
 * @dev Token distributer tool contract mainly includes the following functions:
 * 1. Batch distribute tokens to the specified wallet address.
 * 2. The user who triggers token distribution must have contract ownership.
 * 3. Support the claim of any  ERC20 token to the contract ownership address.
 * 4. Add and remove wallet addresses to the  issuers array.
 * 5. Must match the specified contract address.
 * 6. Cooling time is less than 200 blocks.
 * 7. Quantitative distribution
 **/

contract TokenDistributor is Ownable {

    using SafeMath for uint256;

    address public fundAddress;
    address public issuedToken;

    address[] private issuers;
    mapping(address => uint256) issuerIndex;
    mapping(address => bool) excludeIssuer;

    uint256 private rationCounts;
    uint256 private rationPerissuer;
    uint256 private percentPerCount;
    uint256 private startRationInitBlock;
    uint256 private startPercentInitBlock;
    uint256 private maxgas = 500000;
    uint256 private rationCurrentIndex;
    uint256 private percentCurrentIndex;
    uint256 private rationProgressIssuedBlock;
    uint256 private percentProgressIssuedBlock;

    bool private rationSuperPercent = true;

    event DistributeRation(address from, uint256 value, address token);
    event DistributePercent(address from, uint256 value, address token);
    event ClaimBalance(address fundAddress, uint256 value);
    event ClaimToken(address to, uint256 value, address token);
    event RationSuperPercentUpdated(bool enabled);

    constructor (
        address FundAddress,
        address IssuedToken,
        uint256 RationCounts,
        uint256 PercentPerCount
    ) {
        rationCounts = RationCounts;
        percentPerCount = PercentPerCount;
        fundAddress = FundAddress;
        issuedToken = IssuedToken;
        excludeIssuer[address(0)] = true;
        excludeIssuer[address(0x000000000000000000000000000000000000dEaD)] = true;
    }

    receive() external payable {}

    function startRationInit() external onlyOwner {
        require(startRationInitBlock == 0, "BEP20: RationInitialization has been completed");
        require(rationSuperPercent, "BEP20: Current mode is not ration");

        uint256 balance = IERC20(issuedToken).balanceOf(address(this));
        rationPerissuer = balance.div(rationCounts).div(issuers.length);
        startRationInitBlock = block.number;
    }

    function closeRationInit() external onlyOwner {
        require(startRationInitBlock > 0, "BEP20: RationInitialization has not been completed");
        startRationInitBlock = 0;
    }

    function getStartRationInitBlock() public view returns (uint256) {
        return startRationInitBlock;
    }

    function startPercentInit() external onlyOwner {
        require(startPercentInitBlock == 0, "BEP20: PercentInitialization has been completed");
        require(!rationSuperPercent, "BEP20: Current mode is not percent");

        startPercentInitBlock = block.number;
    }

    function closePercentInit() external onlyOwner {
        require(startPercentInitBlock > 0, "BEP20: PercentInitialization has not been completed");
        startPercentInitBlock = 0;
    }

    function getStartPercentInitBlock() public view returns (uint256) {
        return startPercentInitBlock;
    }

    function distributeRation () external onlyOwner {
        require(startRationInitBlock > 0, "BEP20: RationInitialization has not been completed");
        if (rationProgressIssuedBlock.add(200) > block.number) {
            return;
        }

        IERC20 TOKEN = IERC20(issuedToken);
        uint256 balance = TOKEN.balanceOf(address(this));
        if (balance < rationPerissuer) {
            return;
        }

        uint256 total;
        address shareIssuer;
        uint256 shareIssuerCount = issuers.length;
        uint256 gasUsed = 0;
        uint256 iterations = 0;
        uint256 gasLeft = gasleft();

        while (gasUsed < maxgas && iterations < shareIssuerCount) {
            if (rationCurrentIndex >= shareIssuerCount) {
                rationCurrentIndex = 0;
            }
            shareIssuer = issuers[rationCurrentIndex];
            if (!excludeIssuer[shareIssuer] && balance >= rationPerissuer) {
                TOKEN.transfer(shareIssuer, rationPerissuer);
                balance = balance.sub(rationPerissuer);
                total = total.add(rationPerissuer);
            }

            gasUsed = gasUsed + (gasLeft - gasleft());
            gasLeft = gasleft();
            rationCurrentIndex++;
            iterations++;
        }

        rationProgressIssuedBlock = block.number;
        emit DistributeRation(address(this), total, issuedToken);
    }

    function distributePercent () external onlyOwner {
        require(startPercentInitBlock > 0, "BEP20: PercentInitialization has not been completed");
        if (percentProgressIssuedBlock.add(200) > block.number) {
            return;
        }

        IERC20 TOKEN = IERC20(issuedToken);
        uint256 balance = TOKEN.balanceOf(address(this));
        if (balance == 0) {
            return;
        }

        uint256 total;
        address shareIssuer;
        uint256 shareIssuerCount = issuers.length;
        uint256 gasUsed = 0;
        uint256 iterations = 0;
        uint256 gasLeft = gasleft();
        uint256 percentPerissuer = balance.mul(percentPerCount).div(10000).div(shareIssuerCount);

        while (gasUsed < maxgas && iterations < shareIssuerCount) {
            if (percentCurrentIndex >= shareIssuerCount) {
                percentCurrentIndex = 0;
            }
            shareIssuer = issuers[percentCurrentIndex];
            if (!excludeIssuer[shareIssuer] && balance >= percentPerissuer) {
                TOKEN.transfer(shareIssuer, percentPerissuer);
                balance = balance.sub(percentPerissuer);
                total = total.add(percentPerissuer);
            }

            gasUsed = gasUsed + (gasLeft - gasleft());
            gasLeft = gasleft();
            percentCurrentIndex++;
            iterations++;
        }

        percentProgressIssuedBlock = block.number;
        emit DistributePercent(address(this), total, issuedToken);
    }

    function claimBalance() external onlyOwner {
        uint256 balance = address(this).balance;
        payable(fundAddress).transfer(balance);
        emit ClaimBalance(fundAddress,balance);
    }

    function claimToken(address token, uint256 amount, address to) external onlyOwner {
        require(token != issuedToken, "BEP20: issuedToken has been initialized and cannot be claimed");
        IERC20(token).transfer(to, amount);
        emit ClaimToken(to, amount, token);
    }

    function addIssuer(address adr) external onlyOwner {
        uint256 size;
        assembly {size := extcodesize(adr)}
        if (size > 0) {
            return;
        }
        if (0 == issuerIndex[adr]) {
            if (0 == issuers.length || issuers[0] != adr) {
                issuerIndex[adr] = issuers.length;
                issuers.push(adr);
            }
        }
    }

    function isIssuer(address addr) public view returns (bool) {
        require(addr != address(0), "BEP20: addr is zero address");
        for(uint256 i = 0; i < issuers.length; i++) {
            if(issuers[i] == addr) {
                return true;
            }
        }

        return false;
    }

    function setExcludeIssuer(address addr, bool enable) external onlyOwner {
        require(excludeIssuer[addr] != enable, "BEP20: address has been set enable");
        require(issuers[issuerIndex[addr]] == addr, "BEP20: address is not included in issuers");
        excludeIssuer[addr] = enable;
    }

    function isExcludeIssuer(address addr) public view returns (bool) {
        return excludeIssuer[addr];
    }

    function setFundAddress(address addr) external onlyOwner {
        fundAddress = addr;
    }

    function setIssuedToken(address addr) external onlyOwner {
        issuedToken = addr;
    }

    function setMaxGas(uint256 gas) external onlyOwner {
        maxgas = gas;
    }

    function setRationCounts(uint256 count) external onlyOwner {
        rationCounts = count;
    }
    
    function getRationCounts() public view returns (uint256) {
        return rationCounts;
    }

    function getRationPerissuer() public view returns (uint256) {
        return rationPerissuer;
    }

    function setPercentPerCount(uint256 percent) external onlyOwner {
        percentPerCount = percent;
    }

    function getPercentPerCount() public view returns (uint256) {
        return percentPerCount;
    }

    function setRationSuperPercent (bool enable) external onlyOwner {
        rationSuperPercent = enable;
        emit RationSuperPercentUpdated(enable);
    }

    function getRationSuperPercent() public view returns (bool) {
        return rationSuperPercent;
    }

}