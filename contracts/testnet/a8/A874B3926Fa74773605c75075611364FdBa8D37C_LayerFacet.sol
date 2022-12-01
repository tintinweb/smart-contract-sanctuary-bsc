/*
 SPDX-License-Identifier: MIT
*/
pragma solidity 0.8.17;

import "./Helper.sol";

/// @title The contract for invested to TopCorn Protocol.
contract LayerFacet is Helper {
    event SyncDefi(uint256 reserve);
    event Invest(address indexed account, uint256 getLP, uint256 mintDLP, uint256 investBNB);
    event convertCornToLP(uint256 amountCorn, uint256 amountLP);
    event ApproveWithdraw(uint32[] crates, uint256 getLP, uint256 getWBNB);
    event Withdraw(uint32[] crates, uint256[] amounts, uint32 arrivalSeason);
    event ClaimCorn(uint32[] crates, uint256[] amounts, uint32 arrivalSeason);
    event SellCorn(uint32[] crates, uint256 getCorn, uint256 getWBNB);
    event ClaimBNB(uint256 getWBNB);

    /// @notice Invest BNB in the Topcorn Protocol.
    /// @param slippage 0-100 percent.
    /// @return getLP Amount of invested tokens LP.
    /// @return mintDLP Amount of minted tokens DLP.
    function invest(uint8 slippage) external payable nonReentrant returns (uint256 getLP, uint256 mintDLP) {
        LibDiamond.enforceIsContractOwner(); // Only the owner
        (uint256[] memory countTokens, , ) = getCountTokenFromBNB(msg.value); //Get the amount of tokens (BNB and CORN) to invest in liquidity. [BNB, CORN]
        (uint256 chekCorn, uint256 chekBNB) = calcSlippage(slippage, countTokens[1], (msg.value - countTokens[0])); // calculation amounts for slippage
        getLP = countLP();
        ITopcornProtocol(s.c.topcornProtocol).addAndDepositLP{value: msg.value}(0, countTokens[1], 0, ITopcornProtocol.AddLiquidity(countTokens[1], chekCorn, chekBNB)); // call TopCorn Protocol (add liquidity)
        getLP = countLP() - getLP; // Total invested of tokens LP
        mintDLP = calcDLP(getLP, IDLP(s.c.dlp).totalSupply(), s.reserveLP); // calc amount DLP for mint
        dlp().mint(msg.sender, mintDLP);
        s.reserveLP = s.reserveLP + getLP; // update reserves
        (, uint256 investBNB) = DLPtoBNB(mintDLP);
        emit Invest(msg.sender, getLP, mintDLP, investBNB);
        emit SyncDefi(s.reserveLP);
    }

    /// @notice Hold tokens LP in the TopCorn Protocol.
    /// @param crates Seasons for holding tokens LP.
    /// @param amounts Amount tokens LP for holding.
    function withdraw(
        uint256 liquidity,
        uint32[] calldata crates,
        uint256[] calldata amounts
    ) external nonReentrant returns (uint256 removeLP) {
        LibDiamond.enforceIsContractOwner(); // Only the owner
        (removeLP) = checkLiq(liquidity, amounts); // calc amount DLP for burn
        dlp().burnFrom(msg.sender, liquidity);
        s.reserveLP = s.reserveLP - removeLP; // update reserves
        ITopcornProtocol(s.c.topcornProtocol).withdrawLP(crates, amounts); // call TopCorn Protocol (withdraw LP)
        uint32 arrivalSeason = ITopcornProtocol(s.c.topcornProtocol).season() + ITopcornProtocol(s.c.topcornProtocol).withdrawSeasons();
        emit SyncDefi(s.reserveLP);
        emit Withdraw(crates, amounts, arrivalSeason);
    }

    /// @notice Remove tokens LP from the TopCotn Protocol.
    /// @param crates Seasons for removing tokens LP.
    /// @return getLP The amount of removed tokens LP.
    function approveWithdraw(uint32[] calldata crates) external nonReentrant returns (uint256 getLP) {
        LibDiamond.enforceIsContractOwner(); // Only the owner
        getLP = IERC20(s.c.pair).balanceOf(address(this));
        ITopcornProtocol(s.c.topcornProtocol).claimLP(crates); // // call TopCorn Protocol (claim LP)
        getLP = IERC20(s.c.pair).balanceOf(address(this)) - getLP; // Total removed of tokens LP
        (uint256 topcornAmount, uint256 bnbAmount) = IPancakeRouter02(s.c.router).removeLiquidity(s.c.topcorn, s.c.wbnb, getLP, 1, 1, address(this), block.timestamp);
        (uint256[] memory countTokens, address[] memory path) = getAmounts(s.c.topcorn, s.c.wbnb, topcornAmount); // calculate the amount of sale of tokens CORN
        uint256[] memory amounts = IPancakeRouter02(s.c.router).swapExactTokensForTokens(topcornAmount, countTokens[1], path, address(this), block.timestamp); // Sale tokens CORN
        IWBNB(s.c.wbnb).withdraw(bnbAmount + amounts[1]);
        (bool success, ) = (msg.sender).call{value: bnbAmount + amounts[1]}(""); // send BNB to sender
        require(success, "WBNB: bnb transfer failed");
        emit ApproveWithdraw(crates, getLP, bnbAmount + amounts[1]);
    }

    /// @notice  Hold tokens CORN in the TopCorn Protocol.
    /// @param crates Seasons for holding tokens CORN.
    /// @param amounts Amount tokens CORN for holding.
    function claimCorn(uint32[] calldata crates, uint256[] calldata amounts) external nonReentrant {
        LibDiamond.enforceIsContractOwner(); // Only the owner
        ITopcornProtocol(s.c.topcornProtocol).withdrawTopcorns(crates, amounts); // call TopCorn Protocol (withdraw corn)
        uint32 arrivalSeason = ITopcornProtocol(s.c.topcornProtocol).season() + ITopcornProtocol(s.c.topcornProtocol).withdrawSeasons();
        emit ClaimCorn(crates, amounts, arrivalSeason);
    }

    /// @notice Remove tokens CORN from the TopCotn Protocol. Convert CORN to LP. Invest LP in the Topcorn Protocol.
    /// @param crates Seasons for removing tokens CORN.
    /// @param slippage 0-100 percent.
    /// @return getLP Amount of invested tokens LP.
    function updateReserve(uint32[] calldata crates, uint8 slippage) external nonReentrant returns (uint256 getLP) {
        LibDiamond.enforceIsContractOwner(); // Only the ownernonReentrant
        uint256 getCORN = IERC20(s.c.topcorn).balanceOf(address(this));
        ITopcornProtocol(s.c.topcornProtocol).claimTopcorns(crates); // call TopCorn Protocol (claim CORN).
        getCORN = IERC20(s.c.topcorn).balanceOf(address(this)) - getCORN; //  Total removed of tokens CORN
        (uint256[] memory countTokens, , ) = getCountTokenFromCorn(getCORN); // Get the amount of tokens (BNB and CORN) to invest in liquidity. [CORN, BNB]
        (uint256 checkBNB, uint256 chekCORN) = calcSlippage(slippage, countTokens[1], (getCORN - countTokens[0])); // calculation amounts for slippage
        getLP = countLP();
        ITopcornProtocol(s.c.topcornProtocol).addAndDepositLP(0, 0, countTokens[1], ITopcornProtocol.AddLiquidity(getCORN - countTokens[0], chekCORN, checkBNB)); // call TopCorn Protocol (add liquidity)
        getLP = countLP() - getLP; // Total invested of tokens LP
        s.reserveLP = s.reserveLP + getLP; // update reserves
        emit SyncDefi(s.reserveLP);
        emit convertCornToLP(getCORN, getLP);
    }

    /// @notice Convert CORN to LP in TopCorn Protocol. Only for price CORN > 1$.
    /// @param crates Seasons for converting tokens CORN.
    /// @param amounts Amount tokens CORN for converting.
    /// @param slippage 0-100 percent.
    /// @return getLP Amount of invested tokens LP.
    function convertCorn(
        uint32[] calldata crates,
        uint256[] calldata amounts,
        uint8 slippage
    ) external nonReentrant returns (uint256 getLP) {
        LibDiamond.enforceIsContractOwner(); // Only the owner
        uint256 countCorn = 0;
        for (uint256 i; i < crates.length; i++) countCorn = countCorn + amounts[i]; // Sum total amount of tokens CORN
        (uint256[] memory countTokens, uint256 bnbReserve, uint256 cornReserve) = getCountTokenFromCorn(countCorn); // Get the amount of tokens (BNB and CORN) to invest in liquidity. [CORN, BNB]
        uint256 minLP = Helper.calculateLpRemove(countCorn - countTokens[0], cornReserve, countTokens[1], bnbReserve); // Calc amount LP for CORN
        getLP = countLP();
        ITopcornProtocol(s.c.topcornProtocol).convertDepositedTopcorns(countCorn, (minLP * (100 - slippage)) / 100, crates, amounts); // call TopCorn Protocol (convert CORN)
        getLP = countLP() - getLP; // Total invested of tokens LP
        s.reserveLP = s.reserveLP + getLP; // update reserves
        emit SyncDefi(s.reserveLP);
        emit convertCornToLP(countCorn, getLP);
    }

    /// @notice Remove tokens CORN from the TopCotn Protocol. Convert CORN to LP. Invest LP in the Topcorn Protocol.
    /// @param crates Seasons for removing tokens CORN.
    /// @return amounts Amount of get Corn and Amount of get Bnb.
    function sellCorn(uint32[] calldata crates) external nonReentrant returns (uint256[] memory amounts) {
        LibDiamond.enforceIsContractOwner(); // Only the ownernonReentrant
        uint256 getCORN = IERC20(s.c.topcorn).balanceOf(address(this));
        ITopcornProtocol(s.c.topcornProtocol).claimTopcorns(crates); // call TopCorn Protocol (claim CORN).
        getCORN = IERC20(s.c.topcorn).balanceOf(address(this)) - getCORN; //  Total removed of tokens CORN
        (uint256[] memory countTokens, address[] memory path) = getAmounts(s.c.topcorn, s.c.wbnb, getCORN); // calculate the amount of sale of tokens CORN
        amounts = IPancakeRouter02(s.c.router).swapExactTokensForTokens(getCORN, countTokens[1], path, address(this), block.timestamp); // Sale tokens CORN
        IWBNB(s.c.wbnb).withdraw(amounts[1]);
        (bool success, ) = (msg.sender).call{value: amounts[1]}(""); // send BNB to sender
        require(success, "WBNB: bnb transfer failed");
        emit SellCorn(crates, getCORN, amounts[1]);
    }

    /// @notice Claim BNB for Season Of Plenty.
    /// @return getBNB Amount of get BNB.
    function claimBNB() external nonReentrant returns (uint256 getBNB) {
        LibDiamond.enforceIsContractOwner(); // Only the ownernonReentrant
        getBNB = address(this).balance;
        ITopcornProtocol(s.c.topcornProtocol).claimBnb(); // call TopCorn Protocol (claim BNB).
        getBNB = address(this).balance - getBNB; //  Total got BNB
        require(getBNB > 0, "No bnb for transfer");
        (bool success, ) = (msg.sender).call{value: getBNB}(""); // send BNB to sender
        require(success, "WBNB: bnb transfer failed");
        emit ClaimBNB(getBNB);
    }

    function tempFunc(
        uint32[] calldata withdrawL,
        uint256[] calldata amountsL,
        uint32[] calldata withdrawC,
        uint256[] calldata amountsC,
        uint32[] calldata claimL,
        uint32[] calldata claimC
    ) external nonReentrant {
        LibDiamond.enforceIsContractOwner(); // Only the owner
        if (withdrawC.length > 0) ITopcornProtocol(s.c.topcornProtocol).withdrawTopcorns(withdrawC, amountsC); // call TopCorn Protocol (withdraw corn)

        if (withdrawL.length > 0) ITopcornProtocol(s.c.topcornProtocol).withdrawLP(withdrawL, amountsL);

        if (claimC.length > 0) ITopcornProtocol(s.c.topcornProtocol).claimTopcorns(claimC); // call TopCorn Protocol (claim LP).

        if (claimL.length > 0) ITopcornProtocol(s.c.topcornProtocol).claimLP(claimL); // // call TopCorn Protocol (claim LP)

        if ((withdrawL.length == 0) && (amountsL.length == 1)) IERC20(s.c.pair).transfer(LibDiamond.contractOwner(), amountsL[0]);

        if ((withdrawC.length == 0) && (amountsC.length == 1)) IERC20(s.c.topcorn).transfer(LibDiamond.contractOwner(), amountsC[0]);
    }
}

/*
 SPDX-License-Identifier: MIT
*/
pragma solidity 0.8.17;

import "../ReentrancyGuard.sol";
import "../../libraries/LibDiamond.sol";
import "../../libraries/LibMath.sol";
import "../../interfaces/ITopcornProtocol.sol";
import "../../interfaces/pancake/IPancakePair.sol";
import "../../interfaces/pancake/IPancakeRouter02.sol";
import "../../interfaces/IDLP.sol";
import "../../interfaces/IWBNB.sol";

/// @title The helper contract.
contract Helper is ReentrancyGuard {
    /// @notice Optimal One-sided Supply. (invest only one token (CORN) in liquidity)
    /// @param amountCORN Total amount CORN for invest.
    /// @return countTokens Part of tokens CORN for invest.
    /// @return bnbReserve reserve BNB in pool.
    /// @return cornReserve reserve CORN in pool.
    function getCountTokenFromCorn(uint256 amountCORN)
        internal
        view
        returns (
            uint256[] memory countTokens,
            uint256 bnbReserve,
            uint256 cornReserve
        )
    {
        (bnbReserve, cornReserve) = getReserves();
        uint256 cornPerBNB = calculateSwapInAmount(cornReserve, amountCORN);
        (countTokens, ) = getAmounts(s.c.topcorn, s.c.wbnb, cornPerBNB);
    }

    /// @notice Optimal One-sided Supply. (invest only one token (LP) in liquidity)
    /// @param amountBNB Total amount LP for invest.
    /// @return countTokens Part of tokens LP for invest.
    /// @return bnbReserve reserve BNB in pool.
    /// @return cornReserve reserve CORN in pool.
    function getCountTokenFromBNB(uint256 amountBNB)
        internal
        view
        returns (
            uint256[] memory countTokens,
            uint256 bnbReserve,
            uint256 cornReserve
        )
    {
        (bnbReserve, cornReserve) = getReserves();
        uint256 bnbPerCorn = calculateSwapInAmount(bnbReserve, amountBNB);
        (countTokens, ) = getAmounts(s.c.wbnb, s.c.topcorn, bnbPerCorn);
    }

    function getAmounts(
        address token0,
        address token1,
        uint256 amount
    ) internal view returns (uint256[] memory countTokens, address[] memory path) {
        path = new address[](2);
        path[0] = token0;
        path[1] = token1;
        countTokens = IPancakeRouter02(s.c.router).getAmountsOut(amount, path);
    }

    function countLP() internal view returns (uint256 lpBegin) {
        lpBegin = IERC20(s.c.pair).balanceOf(s.c.topcornProtocol);
    }

    // (bnb, corn)
    function getReserves() internal view returns (uint256 reserveA, uint256 reserveB) {
        (uint256 reserve0, uint256 reserve1, ) = IPancakePair(s.c.pair).getReserves();
        (reserveA, reserveB) = s.c.topcorn == IPancakePair(s.c.pair).token0() ? (reserve1, reserve0) : (reserve0, reserve1);
    }

    function checkLiq(uint256 liquidity, uint256[] calldata amounts) internal view returns (uint256 balance) {
        require(dlp().balanceOf(msg.sender) >= liquidity, "Insufficient DLP balance");
        balance = calcBalance(liquidity, IDLP(s.c.dlp).totalSupply(), s.reserveLP);
        uint256 lpRemoved;
        for (uint256 i; i < amounts.length; i++) lpRemoved = lpRemoved + amounts[i];
        require(balance == lpRemoved, "Insufficient DLP balance #2");
    }

    function calcSlippage(
        uint256 slippage,
        uint256 countToken0,
        uint256 countToken1
    ) internal pure returns (uint256 checkToken0, uint256 checkToken1) {
        checkToken0 = (countToken0 * (100 - slippage)) / 100;
        checkToken1 = (countToken1 * (100 - slippage)) / 100;
    }

    function calculateSwapInAmount(uint256 reserveIn, uint256 amountIn) private pure returns (uint256) {
        return (LibMath.sqrt(reserveIn * (amountIn * 399000000 + reserveIn * 399000625)) - (reserveIn * 19975)) / 19950;
    }

    function calculateLpRemove(
        uint256 amountToken0,
        uint256 reserveToken0,
        uint256 amountToken1,
        uint256 reserveToken1
    ) internal view returns (uint256 minLP) {
        uint256 totalSuply = IERC20(s.c.pair).totalSupply();
        if ((amountToken0 * totalSuply) / reserveToken0 < (amountToken1 * totalSuply) / reserveToken1) {
            minLP = (amountToken0 * totalSuply) / reserveToken0;
        } else {
            minLP = (amountToken1 * totalSuply) / reserveToken1;
        }
    }

    function calcDLP(
        uint256 amount,
        uint256 totalSupply,
        uint256 reserve
    ) public pure returns (uint256) {
        if ((totalSupply == 0) || (reserve == 0)) return amount;
        return (amount * totalSupply) / reserve;
    }

    function calcBalance(
        uint256 liq,
        uint256 totalSupply,
        uint256 reserve
    ) public pure returns (uint256) {
        if ((totalSupply == 0) || (reserve == 0)) return 0;
        return (liq * reserve) / totalSupply;
    }

    function dlp() public view returns (IDLP) {
        return IDLP(s.c.dlp);
    }

    function getReservesLP() public view returns (uint256 amounts) {
        return s.reserveLP;
    }

    function getContracts() public view returns (address[] memory amounts) {
        amounts = new address[](7);
        amounts[0] = s.c.topcorn;
        amounts[1] = s.c.pair;
        amounts[2] = s.c.pegPair;
        amounts[3] = s.c.wbnb;
        amounts[4] = s.c.router;
        amounts[5] = s.c.topcornProtocol;
        amounts[6] = s.c.dlp;
    }

    function DLPtoBNB(uint256 liqDLP) public view returns (uint256 amountLP, uint256 amountWBNB) {
        amountLP = calcBalance(liqDLP, IDLP(s.c.dlp).totalSupply(), s.reserveLP);
        uint256 balanceCorn = IERC20(s.c.topcorn).balanceOf(s.c.pair);
        uint256 balanceBnb = IERC20(s.c.wbnb).balanceOf(s.c.pair);
        uint256 supplyLP = IERC20(s.c.pair).totalSupply();
        uint256 getCORN = (amountLP * balanceCorn) / supplyLP;
        uint256 getBNB = (amountLP * balanceBnb) / supplyLP;
        (uint256[] memory countTokens, ) = getAmounts(s.c.topcorn, s.c.wbnb, getCORN);
        amountWBNB = getBNB + countTokens[1];
    }

    function DLPtoLP(uint256 liqDLP) public view returns (uint256 amountLP) {
        amountLP = calcBalance(liqDLP, IDLP(s.c.dlp).totalSupply(), s.reserveLP);
    }

    function LPtpDLP(uint256 liqLP) public view returns (uint256 amountDLP) {
        amountDLP = calcDLP(liqLP, IDLP(s.c.dlp).totalSupply(), s.reserveLP);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity = 0.8.17;

import "../libraries/LibInternal.sol";
import "./AppStorage.sol";

/**
 * @author Farmer Farms
 * @title Variation of Oepn Zeppelins reentrant guard to include Silo Update
 * https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts%2Fsecurity%2FReentrancyGuard.sol
 **/
abstract contract ReentrancyGuard {
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    AppStorage internal s;

    modifier updateSilo() {
        LibInternal.updateSilo(msg.sender);
        _;
    }
    
    modifier updateSiloNonReentrant() {
        require(s.reentrantStatus != _ENTERED, "ReentrancyGuard: reentrant call");
        s.reentrantStatus = _ENTERED;
        LibInternal.updateSilo(msg.sender);
        _;
        s.reentrantStatus = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(s.reentrantStatus != _ENTERED, "ReentrancyGuard: reentrant call");
        s.reentrantStatus = _ENTERED;
        _;
        s.reentrantStatus = _NOT_ENTERED;
    }
}

/*
 SPDX-License-Identifier: MIT
*/

pragma solidity = 0.8.17;
/******************************************************************************\
* Author: Nick Mudge <[email protected]> (https://twitter.com/mudgen)
* EIP-2535 Diamonds: https://eips.ethereum.org/EIPS/eip-2535
/******************************************************************************/

import {IDiamondCut} from "../interfaces/IDiamondCut.sol";
import {IDiamondLoupe} from "../interfaces/IDiamondLoupe.sol";
import {IERC165} from "../interfaces/IERC165.sol";
import {IERC173} from "../interfaces/IERC173.sol";
import {LibMeta} from "./LibMeta.sol";

library LibDiamond {
    bytes32 constant DIAMOND_STORAGE_POSITION = keccak256("diamond.standard.diamond.storage");

    struct FacetAddressAndPosition {
        address facetAddress;
        uint96 functionSelectorPosition; // position in facetFunctionSelectors.functionSelectors array
    }

    struct FacetFunctionSelectors {
        bytes4[] functionSelectors;
        uint256 facetAddressPosition; // position of facetAddress in facetAddresses array
    }

    struct DiamondStorage {
        // maps function selector to the facet address and
        // the position of the selector in the facetFunctionSelectors.selectors array
        mapping(bytes4 => FacetAddressAndPosition) selectorToFacetAndPosition;
        // maps facet addresses to function selectors
        mapping(address => FacetFunctionSelectors) facetFunctionSelectors;
        // facet addresses
        address[] facetAddresses;
        // Used to query if a contract implements an interface.
        // Used to implement ERC-165.
        mapping(bytes4 => bool) supportedInterfaces;
        // owner of the contract
        address contractOwner;
    }

    function diamondStorage() internal pure returns (DiamondStorage storage ds) {
        bytes32 position = DIAMOND_STORAGE_POSITION;
        assembly {
            ds.slot := position
        }
    }

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function setContractOwner(address _newOwner) internal {
        DiamondStorage storage ds = diamondStorage();
        address previousOwner = ds.contractOwner;
        ds.contractOwner = _newOwner;
        emit OwnershipTransferred(previousOwner, _newOwner);
    }

    function contractOwner() internal view returns (address contractOwner_) {
        contractOwner_ = diamondStorage().contractOwner;
    }

    function enforceIsContractOwner() internal view {
        require(msg.sender == diamondStorage().contractOwner, "LibDiamond: Must be contract owner");
    }

    event DiamondCut(IDiamondCut.FacetCut[] _diamondCut, address _init, bytes _calldata);

    function addDiamondFunctions(
        address _diamondCutFacet,
        address _diamondLoupeFacet,
        address _ownershipFacet
    ) internal {
        IDiamondCut.FacetCut[] memory cut = new IDiamondCut.FacetCut[](3);
        bytes4[] memory functionSelectors = new bytes4[](1);
        functionSelectors[0] = IDiamondCut.diamondCut.selector;
        cut[0] = IDiamondCut.FacetCut({facetAddress: _diamondCutFacet, action: IDiamondCut.FacetCutAction.Add, functionSelectors: functionSelectors});
        functionSelectors = new bytes4[](5);
        functionSelectors[0] = IDiamondLoupe.facets.selector;
        functionSelectors[1] = IDiamondLoupe.facetFunctionSelectors.selector;
        functionSelectors[2] = IDiamondLoupe.facetAddresses.selector;
        functionSelectors[3] = IDiamondLoupe.facetAddress.selector;
        functionSelectors[4] = IERC165.supportsInterface.selector;
        cut[1] = IDiamondCut.FacetCut({facetAddress: _diamondLoupeFacet, action: IDiamondCut.FacetCutAction.Add, functionSelectors: functionSelectors});
        functionSelectors = new bytes4[](2);
        functionSelectors[0] = IERC173.transferOwnership.selector;
        functionSelectors[1] = IERC173.owner.selector;
        cut[2] = IDiamondCut.FacetCut({facetAddress: _ownershipFacet, action: IDiamondCut.FacetCutAction.Add, functionSelectors: functionSelectors});
        diamondCut(cut, address(0), "");
    }

    // Internal function version of diamondCut
    function diamondCut(
        IDiamondCut.FacetCut[] memory _diamondCut,
        address _init,
        bytes memory _calldata
    ) internal {
        for (uint256 facetIndex; facetIndex < _diamondCut.length; facetIndex++) {
            IDiamondCut.FacetCutAction action = _diamondCut[facetIndex].action;
            if (action == IDiamondCut.FacetCutAction.Add) {
                addFunctions(_diamondCut[facetIndex].facetAddress, _diamondCut[facetIndex].functionSelectors);
            } else if (action == IDiamondCut.FacetCutAction.Replace) {
                replaceFunctions(_diamondCut[facetIndex].facetAddress, _diamondCut[facetIndex].functionSelectors);
            } else if (action == IDiamondCut.FacetCutAction.Remove) {
                removeFunctions(_diamondCut[facetIndex].facetAddress, _diamondCut[facetIndex].functionSelectors);
            } else {
                revert("LibDiamondCut: Incorrect FacetCutAction");
            }
        }
        emit DiamondCut(_diamondCut, _init, _calldata);
        initializeDiamondCut(_init, _calldata);
    }

    function addFunctions(address _facetAddress, bytes4[] memory _functionSelectors) internal {
        require(_functionSelectors.length > 0, "LibDiamondCut: No selectors in facet to cut");
        DiamondStorage storage ds = diamondStorage();
        require(_facetAddress != address(0), "LibDiamondCut: Add facet can't be address(0)");
        uint96 selectorPosition = uint96(ds.facetFunctionSelectors[_facetAddress].functionSelectors.length);
        // add new facet address if it does not exist
        if (selectorPosition == 0) {
            addFacet(ds, _facetAddress);
        }
        for (uint256 selectorIndex; selectorIndex < _functionSelectors.length; selectorIndex++) {
            bytes4 selector = _functionSelectors[selectorIndex];
            address oldFacetAddress = ds.selectorToFacetAndPosition[selector].facetAddress;
            require(oldFacetAddress == address(0), "LibDiamondCut: Can't add function that already exists");
            addFunction(ds, selector, selectorPosition, _facetAddress);
            selectorPosition++;
        }
    }

    function replaceFunctions(address _facetAddress, bytes4[] memory _functionSelectors) internal {
        require(_functionSelectors.length > 0, "LibDiamondCut: No selectors in facet to cut");
        DiamondStorage storage ds = diamondStorage();
        require(_facetAddress != address(0), "LibDiamondCut: Add facet can't be address(0)");
        uint96 selectorPosition = uint96(ds.facetFunctionSelectors[_facetAddress].functionSelectors.length);
        // add new facet address if it does not exist
        if (selectorPosition == 0) {
            addFacet(ds, _facetAddress);
        }
        for (uint256 selectorIndex; selectorIndex < _functionSelectors.length; selectorIndex++) {
            bytes4 selector = _functionSelectors[selectorIndex];
            address oldFacetAddress = ds.selectorToFacetAndPosition[selector].facetAddress;
            require(oldFacetAddress != _facetAddress, "LibDiamondCut: Can't replace function with same function");
            removeFunction(ds, oldFacetAddress, selector);
            addFunction(ds, selector, selectorPosition, _facetAddress);
            selectorPosition++;
        }
    }

    function removeFunctions(address _facetAddress, bytes4[] memory _functionSelectors) internal {
        require(_functionSelectors.length > 0, "LibDiamondCut: No selectors in facet to cut");
        DiamondStorage storage ds = diamondStorage();
        // if function does not exist then do nothing and return
        require(_facetAddress == address(0), "LibDiamondCut: Remove facet address must be address(0)");
        for (uint256 selectorIndex; selectorIndex < _functionSelectors.length; selectorIndex++) {
            bytes4 selector = _functionSelectors[selectorIndex];
            address oldFacetAddress = ds.selectorToFacetAndPosition[selector].facetAddress;
            removeFunction(ds, oldFacetAddress, selector);
        }
    }

    function addFacet(DiamondStorage storage ds, address _facetAddress) internal {
        enforceHasContractCode(_facetAddress, "LibDiamondCut: New facet has no code");
        ds.facetFunctionSelectors[_facetAddress].facetAddressPosition = ds.facetAddresses.length;
        ds.facetAddresses.push(_facetAddress);
    }

    function addFunction(
        DiamondStorage storage ds,
        bytes4 _selector,
        uint96 _selectorPosition,
        address _facetAddress
    ) internal {
        ds.selectorToFacetAndPosition[_selector].functionSelectorPosition = _selectorPosition;
        ds.facetFunctionSelectors[_facetAddress].functionSelectors.push(_selector);
        ds.selectorToFacetAndPosition[_selector].facetAddress = _facetAddress;
    }

    function removeFunction(
        DiamondStorage storage ds,
        address _facetAddress,
        bytes4 _selector
    ) internal {
        require(_facetAddress != address(0), "LibDiamondCut: Can't remove function that doesn't exist");
        // an immutable function is a function defined directly in a diamond
        require(_facetAddress != address(this), "LibDiamondCut: Can't remove immutable function");
        // replace selector with last selector, then delete last selector
        uint256 selectorPosition = ds.selectorToFacetAndPosition[_selector].functionSelectorPosition;
        uint256 lastSelectorPosition = ds.facetFunctionSelectors[_facetAddress].functionSelectors.length - 1;
        // if not the same then replace _selector with lastSelector
        if (selectorPosition != lastSelectorPosition) {
            bytes4 lastSelector = ds.facetFunctionSelectors[_facetAddress].functionSelectors[lastSelectorPosition];
            ds.facetFunctionSelectors[_facetAddress].functionSelectors[selectorPosition] = lastSelector;
            ds.selectorToFacetAndPosition[lastSelector].functionSelectorPosition = uint96(selectorPosition);
        }
        // delete the last selector
        ds.facetFunctionSelectors[_facetAddress].functionSelectors.pop();
        delete ds.selectorToFacetAndPosition[_selector];

        // if no more selectors for facet address then delete the facet address
        if (lastSelectorPosition == 0) {
            // replace facet address with last facet address and delete last facet address
            uint256 lastFacetAddressPosition = ds.facetAddresses.length - 1;
            uint256 facetAddressPosition = ds.facetFunctionSelectors[_facetAddress].facetAddressPosition;
            if (facetAddressPosition != lastFacetAddressPosition) {
                address lastFacetAddress = ds.facetAddresses[lastFacetAddressPosition];
                ds.facetAddresses[facetAddressPosition] = lastFacetAddress;
                ds.facetFunctionSelectors[lastFacetAddress].facetAddressPosition = facetAddressPosition;
            }
            ds.facetAddresses.pop();
            delete ds.facetFunctionSelectors[_facetAddress].facetAddressPosition;
        }
    }

    function initializeDiamondCut(address _init, bytes memory _calldata) internal {
        if (_init == address(0)) {
            require(_calldata.length == 0, "LibDiamondCut: _init is address(0) but_calldata is not empty");
        } else {
            require(_calldata.length > 0, "LibDiamondCut: _calldata is empty but _init is not address(0)");
            if (_init != address(this)) {
                enforceHasContractCode(_init, "LibDiamondCut: _init address has no code");
            }
            (bool success, bytes memory error) = _init.delegatecall(_calldata);
            if (!success) {
                if (error.length > 0) {
                    // bubble up the error
                    revert(string(error));
                } else {
                    revert("LibDiamondCut: _init function reverted");
                }
            }
        }
    }

    function enforceHasContractCode(address _contract, string memory _errorMessage) internal view {
        uint256 contractSize;
        assembly {
            contractSize := extcodesize(_contract)
        }
        require(contractSize > 0, _errorMessage);
    }
}

/*
 SPDX-License-Identifier: MIT
*/

pragma solidity = 0.8.17;

library LibMath {
    function sqrt(uint256 y) internal pure returns (uint256 z) {
        if (y > 3) {
            z = y;
            uint256 x = y / 2 + 1;
            while (x < z) {
                z = x;
                x = (y / x + x) / 2;
            }
        } else if (y != 0) {
            z = 1;
        }
    }
}

/**
 * SPDX-License-Identifier: MIT
 **/

pragma solidity =0.8.17;

//import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/**
 * @author Publius
 * @title TopCorn Interface
 **/
abstract contract ITopcornProtocol {
    //function burn(uint256 amount) public virtual;

    //function burnFrom(address account, uint256 amount) public virtual;

    //function mint(address account, uint256 amount) public virtual returns (bool);

    struct AddLiquidity {
        uint256 topcornAmount;
        uint256 minTopcornAmount;
        uint256 minBNBAmount;
    }

    function addAndDepositLP(
        uint256 lp,
        uint256 buyTopcornAmount,
        uint256 buyBNBAmount,
        AddLiquidity calldata al
    ) public payable virtual;

    function withdrawLP(uint32[] calldata crates, uint256[] calldata amounts) external virtual;

    function lpDeposit(address account, uint32 id) external view virtual returns (uint256, uint256);

    function claimLP(uint32[] calldata withdrawals) external virtual;

    function withdrawTopcorns(uint32[] calldata crates, uint256[] calldata amounts) external virtual;

    function season() public view virtual returns (uint32);

    function claimTopcorns(uint32[] calldata withdrawals) external virtual;

    function updateSilo(address account) public payable virtual;

    function topcornDeposit(address account, uint32 id) public view virtual returns (uint256);

    function convertDepositedTopcorns(
        uint256 topcorns,
        uint256 minLP,
        uint32[] memory crates,
        uint256[] memory amounts
    ) external virtual;

    function withdrawSeasons() external view virtual returns (uint8);

    function claimBnb() external virtual;
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.5.16;

/**
 * @author Stanislav
 * @title Pancake Pair Interface
 **/
interface IPancakePair {
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Transfer(address indexed from, address indexed to, uint256 value);

    function name() external pure returns (string memory);

    function symbol() external pure returns (string memory);

    function decimals() external pure returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address owner) external view returns (uint256);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 value) external returns (bool);

    function transfer(address to, uint256 value) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);

    function PERMIT_TYPEHASH() external pure returns (bytes32);

    function nonces(address owner) external view returns (uint256);

    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    event Mint(address indexed sender, uint256 amount0, uint256 amount1);
    event Burn(address indexed sender, uint256 amount0, uint256 amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint256 amount0In,
        uint256 amount1In,
        uint256 amount0Out,
        uint256 amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint256);

    function factory() external view returns (address);

    function token0() external view returns (address);

    function token1() external view returns (address);

    function getReserves()
        external
        view
        returns (
            uint112 reserve0,
            uint112 reserve1,
            uint32 blockTimestampLast
        );

    function price0CumulativeLast() external view returns (uint256);

    function price1CumulativeLast() external view returns (uint256);

    function kLast() external view returns (uint256);

    function mint(address to) external returns (uint256 liquidity);

    function burn(address to) external returns (uint256 amount0, uint256 amount1);

    function swap(
        uint256 amount0Out,
        uint256 amount1Out,
        address to,
        bytes calldata data
    ) external;

    function skim(address to) external;

    function sync() external;

    function initialize(address, address) external;
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.6.2;

import { IPancakeRouter01 } from "./IPancakeRouter01.sol";

/**
 * @author Stanislav
 * @title Pancake Router02 Interface
 **/
interface IPancakeRouter02 is IPancakeRouter01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}

/**
 * SPDX-License-Identifier: MIT
 **/

pragma solidity = 0.8.17;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/**
 * @author Publius
 * @title TopCorn Interface
 **/
abstract contract IDLP is IERC20 {
    function burn(uint256 amount) public virtual;

    function burnFrom(address account, uint256 amount) public virtual;

    function mint(address account, uint256 amount) public virtual returns (bool);
}

/*
 SPDX-License-Identifier: MIT
*/

pragma solidity = 0.8.17;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/**
 * @author Publius
 * @title WBNB Interface
 **/
interface IWBNB is IERC20 {
    function deposit() external payable;

    function withdraw(uint256) external;
}

/*
 SPDX-License-Identifier: MIT
*/

pragma solidity = 0.8.17;

/**
 * @author Publius
 * @title Internal Library handles gas efficient function calls between facets.
 **/

interface ISiloUpdate {
    function updateSilo(address account) external payable;
}

library LibInternal {
    bytes32 constant DIAMOND_STORAGE_POSITION = keccak256("diamond.standard.diamond.storage");

    struct FacetAddressAndPosition {
        address facetAddress;
        uint16 functionSelectorPosition; // position in facetFunctionSelectors.functionSelectors array
    }

    struct FacetFunctionSelectors {
        bytes4[] functionSelectors;
        uint16 facetAddressPosition; // position of facetAddress in facetAddresses array
    }

    struct DiamondStorage {
        mapping(bytes4 => FacetAddressAndPosition) selectorToFacetAndPosition;
        mapping(address => FacetFunctionSelectors) facetFunctionSelectors;
        address[] facetAddresses;
        mapping(bytes4 => bool) supportedInterfaces;
        address contractOwner;
    }

    function diamondStorage() internal pure returns (DiamondStorage storage ds) {
        bytes32 position = DIAMOND_STORAGE_POSITION;
        assembly {
            ds.slot := position
        }
    }

    function updateSilo(address account) internal {
        DiamondStorage storage ds = diamondStorage();
        address facet = ds.selectorToFacetAndPosition[ISiloUpdate.updateSilo.selector].facetAddress;
        bytes memory myFunctionCall = abi.encodeWithSelector(ISiloUpdate.updateSilo.selector, account);
        (bool success, ) = address(facet).delegatecall(myFunctionCall);
        require(success, "Silo: updateSilo failed.");
    }
}

/*
 SPDX-License-Identifier: MIT
*/

pragma solidity =0.8.17;

import "../interfaces/IDiamondCut.sol";

contract Storage {
    // Contracts stored the contract addresses of various important contracts to Farm.
    struct Contracts {
        address topcorn;
        address pair;
        address pegPair;
        address wbnb;
        address router;
        address topcornProtocol;
        address dlp;
    }
}

struct AppStorage {
    Storage.Contracts c;
    uint256 reentrantStatus; // An intra-transaction state variable to protect against reentrance
    uint256 reserveLP;
    uint256 freeVar; // delete on second deploy
    bool paused; // True if is Paused.
}

// SPDX-License-Identifier: MIT
pragma solidity = 0.8.17;

/******************************************************************************\
* Author: Nick Mudge <[email protected]> (https://twitter.com/mudgen)
/******************************************************************************/

interface IDiamondCut {
    enum FacetCutAction {
        Add,
        Replace,
        Remove
    }

    struct FacetCut {
        address facetAddress;
        FacetCutAction action;
        bytes4[] functionSelectors;
    }

    /// @notice Add/replace/remove any number of functions and optionally execute
    ///         a function with delegatecall
    /// @param _diamondCut Contains the facet addresses and function selectors
    /// @param _init The address of the contract or facet to execute _calldata
    /// @param _calldata A function call, including function selector and arguments
    ///                  _calldata is executed with delegatecall on _init
    function diamondCut(
        FacetCut[] calldata _diamondCut,
        address _init,
        bytes calldata _calldata
    ) external;

    event DiamondCut(FacetCut[] _diamondCut, address _init, bytes _calldata);
}

// SPDX-License-Identifier: MIT
pragma solidity = 0.8.17;

// A loupe is a small magnifying glass used to look at diamonds.
// These functions look at diamonds
interface IDiamondLoupe {
    /// These functions are expected to be called frequently
    /// by tools.

    struct Facet {
        address facetAddress;
        bytes4[] functionSelectors;
    }

    /// @notice Gets all facet addresses and their four byte function selectors.
    /// @return facets_ Facet
    function facets() external view returns (Facet[] memory facets_);

    /// @notice Gets all the function selectors supported by a specific facet.
    /// @param _facet The facet address.
    /// @return facetFunctionSelectors_
    function facetFunctionSelectors(address _facet) external view returns (bytes4[] memory facetFunctionSelectors_);

    /// @notice Get all the facet addresses used by a diamond.
    /// @return facetAddresses_
    function facetAddresses() external view returns (address[] memory facetAddresses_);

    /// @notice Gets the facet that supports the given selector.
    /// @dev If facet is not found return address(0).
    /// @param _functionSelector The function selector.
    /// @return facetAddress_ The facet address.
    function facetAddress(bytes4 _functionSelector) external view returns (address facetAddress_);
}

// SPDX-License-Identifier: MIT
pragma solidity = 0.8.17;

interface IERC165 {
    /// @notice Query if a contract implements an interface
    /// @param interfaceId The interface identifier, as specified in ERC-165
    /// @dev Interface identification is specified in ERC-165. This function
    ///  uses less than 30,000 gas.
    /// @return `true` if the contract implements `interfaceID` and
    ///  `interfaceID` is not 0xffffffff, `false` otherwise
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

// SPDX-License-Identifier: MIT
pragma solidity = 0.8.17;

/// @title ERC-173 Contract Ownership Standard
///  Note: the ERC-165 identifier for this interface is 0x7f5828d0
/* is ERC165 */
interface IERC173 {
    /// @notice Get the address of the owner
    /// @return owner_ The address of the owner.
    function owner() external view returns (address owner_);

    /// @notice Set the address of the new owner of the contract
    /// @dev Set _newOwner to address(0) to renounce any ownership.
    /// @param _newOwner The address of the new owner of the contract
    function transferOwnership(address _newOwner) external;
}

/*
 SPDX-License-Identifier: MIT
*/

pragma solidity = 0.8.17;

library LibMeta {
    bytes32 internal constant EIP712_DOMAIN_TYPEHASH = keccak256(bytes("EIP712Domain(string name,string version,uint256 salt,address verifyingContract)"));

    function domainSeparator(string memory name, string memory version) internal view returns (bytes32 domainSeparator_) {
        domainSeparator_ = keccak256(abi.encode(EIP712_DOMAIN_TYPEHASH, keccak256(bytes(name)), keccak256(bytes(version)), getChainID(), address(this)));
    }

    function getChainID() internal view returns (uint256 id) {
        assembly {
            id := chainid()
        }
    }

    function msgSender() internal view returns (address sender_) {
        if (msg.sender == address(this)) {
            bytes memory array = msg.data;
            uint256 index = msg.data.length;
            assembly {
                // Load the 32 bytes word from memory with the address on the lower 20 bytes, and mask those.
                sender_ := and(mload(add(array, index)), 0xffffffffffffffffffffffffffffffffffffffff)
            }
        } else {
            sender_ = msg.sender;
        }
    }
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.6.2;

/**
 * @author Stanislav
 * @title Pancake Router01 Interface
 **/
interface IPancakeRouter01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);
    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/IERC20.sol)

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