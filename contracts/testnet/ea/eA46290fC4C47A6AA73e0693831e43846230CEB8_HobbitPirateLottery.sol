// SPDX-License-Identifier: None

import "./library/addressChecker.sol";
import "./library/ReentrancyGuard.sol";
import "./interface/IWrapper.sol";
import "./abstract/Context.sol";

pragma solidity ^0.8.0;

contract HobbitPirateLottery is Context, ReentrancyGuard{
    using addressChecker for address;

    enum slotChoose{
        one_digit,
        two_digit,
        three_digit,
        four_digit
    }

    struct lotteryConfigData{
        uint256 blockDuration;
        uint256 maxUsersOwnTicket;
        uint256 winnerLoopParam;
        uint256 winnerRangeParam;
        uint256 winnerStackParam;
    }

    struct lotteryData{
        uint256 lotteryEndBlock;
        uint256 lotteryPool;
    }

    uint256 private ticketPrice;

    address immutable public wrapper;
    address immutable public feeReceiver;

    mapping(slotChoose => uint256) private currentPeriod;
    mapping(slotChoose => lotteryConfigData) private lotteryConfig;
    mapping(
        uint256 => mapping(slotChoose => lotteryData)
    ) private lotteryDetail;
    mapping(
        uint256 => mapping(
            slotChoose => mapping(uint256 => address)
        )
    ) private ticketOwner;
    mapping(
        uint256 => mapping(
            slotChoose => mapping(uint256 => bool)
        )
    ) private winTicketClaimmed;
    mapping(
        address => mapping(
            uint256 => mapping(slotChoose => uint256[])
        )
    ) private usersChoosedNumber;

    event ticketSold(
        address indexed buyer,
        uint256 indexed period,
        slotChoose indexed slot,
        uint256[] tickets
    );
    event winnerTicket(
        uint256 indexed period,
        slotChoose indexed slot,
        uint256 indexed ticketId,
        address owner,
        uint256 amountWin
    );

    constructor(
        address receiverFee,
        address asset,
        uint256 price,
        uint256[4] memory blockDuration,
        uint256[4] memory maxUsersOwnTicket,
        uint256[4] memory winnerLoopParam,
        uint256[4] memory winnerRangeParam,
        uint256[4] memory winnerStackParam
    ){
        require(
            asset.isBEP20(),
            "HobbitPirateLottery: This address is not BEP20 !"
        );
        require(
            blockDuration.length == 4,
            "HobbitPirateLottery: Fill all value !"
        );
        require(
            blockDuration.length == maxUsersOwnTicket.length &&
            maxUsersOwnTicket.length == winnerLoopParam.length &&
            winnerLoopParam.length == winnerRangeParam.length &&
            winnerRangeParam.length == winnerStackParam.length,
            "HobbitPirateLottery: Fill all value !"
        );

        lotteryConfig[slotChoose.four_digit] = lotteryConfigData(
            blockDuration[3],
            maxUsersOwnTicket[3],
            winnerLoopParam[3],
            winnerRangeParam[3],
            winnerStackParam[3]
        );

        lotteryConfig[slotChoose.three_digit] = lotteryConfigData(
            blockDuration[2],
            maxUsersOwnTicket[2],
            winnerLoopParam[2],
            winnerRangeParam[2],
            winnerStackParam[2]
        );

        lotteryConfig[slotChoose.two_digit] = lotteryConfigData(
            blockDuration[1],
            maxUsersOwnTicket[1],
            winnerLoopParam[1],
            winnerRangeParam[1],
            winnerStackParam[1]
        );

        lotteryConfig[slotChoose.one_digit] = lotteryConfigData(
            blockDuration[0],
            maxUsersOwnTicket[0],
            winnerLoopParam[0],
            winnerRangeParam[0],
            winnerStackParam[0]
        );

        ticketPrice = price;

        wrapper = asset;
        feeReceiver = receiverFee;
    }

    receive() external payable{
        require(
            _msgSender() == wrapper,
            "HobbitPirateLottery : Only accept from wrapper"
        );
    }

    function buyTicket(
        slotChoose slot,
        uint256[] memory ticket
    ) external payable virtual nonReentrant{
        if(
            block.number > getLotteryData(
                getCurrentPeriod(slot),
                slot
            ).lotteryEndBlock
        ){
            uint256 temp = getLotteryConfigData(slot).blockDuration;

            currentPeriod[slot] += 1;

            lotteryDetail[
                getCurrentPeriod(slot)
            ][slot].lotteryEndBlock = block.number + temp;
        }

        require(
            (
                getUserTickets(
                    slot,
                    getCurrentPeriod(slot),
                    _msgSender()
                ).length + ticket.length
            ) <= getLotteryConfigData(slot).maxUsersOwnTicket,
            "HobbitPirateLottery: Maximum limitation is reached!"
        );
        for(uint256 a; a < ticket.length; a++){
            require(
                getTicketOwner(
                    slot,
                    getCurrentPeriod(slot),
                    ticket[a]
                ) == address(0),
                "HobbitPirateLottery: This ticket already choosed somebody!"
            );
        }

        require(
            msg.value == (getTicketPrice() * ticket.length),
            "HobbitPirateLottery: Insufficient value!"
        );
        IWrapper(wrapper).deposit{
            value: getTicketPrice() * ticket.length
        }();

        lotteryDetail[
            getCurrentPeriod(slot)
        ][slot].lotteryPool += getTicketPrice() * ticket.length;

        for(uint256 b; b < ticket.length; b++){
            ticketOwner[
                getCurrentPeriod(slot)
            ][slot][ticket[b]] = _msgSender();
            usersChoosedNumber[
                _msgSender()
            ][getCurrentPeriod(slot)][slot].push(ticket[b]);
        }

        emit ticketSold(
            _msgSender(),
            getCurrentPeriod(slot),
            slot,
            ticket
        );
    }

    function claimZeroWin(
        slotChoose slot,
        uint256 periodId,
        uint256 ticketId
    ) external virtual nonReentrant{
        require(
            _msgSender() == feeReceiver,
            "HobbitPirateLottery: You not allow do this action!"
        );
        require(
            getTicketOwner(
                slot,
                periodId,
                ticketId
            ) == address(0),
            "HobbitPirateLottery: This ticket is not yours!"
        );
        require(
            isTicketWinner(
                slot,
                periodId,
                ticketId
            ),
            "HobbitPirateLottery: This ticket is not Win!"
        );
        require(
            !winTicketClaimmed[periodId][slot][ticketId],
            "HobbitPirateLottery: Already claimmed!"
        );

        uint256 amountWin = getLotteryData(
            periodId,
            slot
        ).lotteryPool / getLotteryConfigData(
            slot
        ).winnerLoopParam;

        IWrapper(wrapper).withdraw(amountWin);
        winTicketClaimmed[periodId][slot][ticketId] = true;

        payable(feeReceiver).transfer(amountWin);
    }

    function claimWin(
        slotChoose slot,
        uint256 periodId,
        uint256 ticketId
    ) external virtual nonReentrant{
        require(
            getTicketOwner(
                slot,
                periodId,
                ticketId
            ) == _msgSender(),
            "HobbitPirateLottery: This ticket is not yours!"
        );
        require(
            isTicketWinner(
                slot,
                periodId,
                ticketId
            ),
            "HobbitPirateLottery: This ticket is not Win!"
        );
        require(
            !winTicketClaimmed[periodId][slot][ticketId],
            "HobbitPirateLottery: Already claimmed!"
        );

        uint256 amountWin = getLotteryData(
            periodId,
            slot
        ).lotteryPool / getLotteryConfigData(
            slot
        ).winnerLoopParam;

        IWrapper(wrapper).withdraw(amountWin);
        winTicketClaimmed[periodId][slot][ticketId] = true;

        uint256 fee = (amountWin * 20) / 100;
        amountWin -= fee;

        payable(_msgSender()).transfer(amountWin);
        payable(feeReceiver).transfer(fee);

        emit winnerTicket(
            periodId,
            slot,
            ticketId,
            _msgSender(),
            amountWin
        );
    }

    function getCurrentPeriod(
        slotChoose slot
    ) public view returns(uint256){
        return currentPeriod[slot];
    }

    function getTicketPrice() public view returns(uint256){
        return ticketPrice;
    }

    function getLotteryData(
        uint256 periodId,
        slotChoose slot
    ) public view returns(lotteryData memory){
        return lotteryDetail[periodId][slot];
    }

    function getLotteryConfigData(
        slotChoose slot
    ) public view returns(lotteryConfigData memory){
        return lotteryConfig[slot];
    }

    function getTicketOwner(
        slotChoose slot,
        uint256 periodId,
        uint256 ticketId
    ) public view returns(address){
        require(
            periodId <= getCurrentPeriod(slot),
            "HobbitPirateLottery: This lottery period is not started yet!"
        );

        if(slot == slotChoose.one_digit){
            require(
                ticketId < 10,
                "HobbitPirateLottery: Slot 1 only accept 0 - 9!"
            );
        }
        if(slot == slotChoose.two_digit){
            require(
                ticketId < 100,
                "HobbitPirateLottery: Slot 2 only accept 0 - 99!"
            );
        }
        if(slot == slotChoose.three_digit){
            require(
                ticketId < 1000,
                "HobbitPirateLottery: Slot 3 only accept 0 - 999!"
            );
        }
        if(slot == slotChoose.four_digit){
            require(
                ticketId < 10000,
                "HobbitPirateLottery: Slot 4 only accept 0 - 9999!"
            );
        }

        return ticketOwner[periodId][slot][ticketId];
    }

    function getUserTickets(
        slotChoose slot,
        uint256 periodId,
        address user
    ) public view returns(uint256[] memory){
        require(
            periodId <= getCurrentPeriod(slot),
            "HobbitPirateLottery: This lottery period is not started yet!"
        );

        return usersChoosedNumber[user][periodId][slot];
    }

    function getWinner(
        slotChoose slot,
        uint256 periodId
    ) public view returns(uint256[] memory){
        require(
            periodId <= getCurrentPeriod(slot),
            "HobbitPirateLottery: This lottery period is not started yet!"
        );
        require(
            block.number > getLotteryData(periodId, slot).lotteryEndBlock,
            "HobbitPirateLottery: Please wait until block elapsed!"
        );
        
        return winnerPicker(
            getLotteryData(periodId, slot).lotteryEndBlock,
            getLotteryConfigData(slot).winnerLoopParam,
            getLotteryConfigData(slot).winnerRangeParam,
            getLotteryConfigData(slot).winnerStackParam
        );
    }

    function isTicketWinner(
        slotChoose slot,
        uint256 period,
        uint256 ticket
    ) private view returns(bool){
        uint256[] memory winner = getWinner(
            slot,
            period
        );

        for(uint256 a; a < winner.length; a++){
            if(ticket == winner[a]){
                return true;
            }
        }

        return false;
    }

    function winnerPicker(
        uint256 blockend,
        uint256 loop,
        uint256 range,
        uint256 stack
    ) private view returns(uint256[] memory){
        uint256[] memory temp = new uint256[](loop);

        for(uint256 a; a < loop; a++){
            uint256 tempadd = a * stack;
            temp[a] = (
                (
                    uint256(
                        blockhash(blockend - 1)
                    ) +
                    (
                        uint256(
                            keccak256(
                                abi.encodePacked(blockend, a)
                            )
                        ) % range
                    )
                )
                % range
            ) + tempadd;
        }

        return temp;
    }

}

// SPDX-License-Identifier: none

pragma solidity ^0.8.0;

import "../interface/IBEP20.sol";
import "../interface/ILiquidity.sol";
import "../interface/IERC721Metadata.sol";

import "./ERC165Checker.sol";

library addressChecker{
    using ERC165Checker for address;

    function isBEP20(
        address target
    ) internal view returns(bool) {
        return _tryIsBEP20(target);
    }

    function isLiquidity(
        address target
    ) internal view returns(bool) {
        return _tryIsLiquidity(target);
    }

    function isERC721(
        address target
    ) internal view returns(bool) {
        bytes4 erc721interface = type(IERC721Metadata).interfaceId;
        
        return target.supportsInterface(erc721interface);
    }

    function _tryIsBEP20(
        address target
    ) private view returns(bool) {
        try IBEP20(target).decimals() returns(uint8 decimals) {
            return decimals > 0;
        }catch{
            return false;
        }
    }

    function _tryIsLiquidity(
        address target
    ) private view returns(bool) {
        address tempToken0;
        address tempToken1;

        try ILiquidity(target).token0() returns(address token0) {
            tempToken0 = token0;
        }catch{
            return false;
        }

        try ILiquidity(target).token1() returns(address token1) {
            tempToken1 = token1;
        }catch{
            return false;
        }

        return (tempToken0 != address(0) && tempToken1 != address(0));
    }
}

// SPDX-License-Identifier: none

pragma solidity ^0.8.0;

abstract contract ReentrancyGuard {
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");
        _status = _ENTERED;
        _;
        _status = _NOT_ENTERED;
    }
}

// SPDX-License-Identifier: none

pragma solidity ^0.8.0;

interface IWrapper{
    function totalSupply() external view returns (uint);
    
    function balanceOf(
        address account
    ) external view returns (uint256);
    
    function allowance(
        address owner,
        address spender
    ) external view returns (uint256);
    
    function deposit() external payable;
    
    function withdraw(
        uint256 amount
    ) external;

    function approve(
        address spender,
        uint256 amount
    ) external;
    
    function transfer(
        address destination,
        uint256 amount
    ) external;
    
    function transferFrom(
        address owner,
        address destination,
        uint256 amount
    ) external;
}

// SPDX-License-Identifier: none

pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

// SPDX-License-Identifier: none

pragma solidity ^0.8.0;

interface IBEP20 {
    function totalSupply() external view returns (uint256);
    function decimals() external view returns (uint8);
    function symbol() external view returns (string memory);
    function name() external view returns (string memory);
    function balanceOf(
        address account
    ) external view returns (uint256);
    function burn(
        uint256 amount
    ) external returns (bool);
    function transfer(
        address recipient,
        uint256 amount
    ) external returns (bool);
    function allowance(
        address _owner,
        address spender
    ) external view returns (uint256);
    function approve(
        address spender,
        uint256 amount
    ) external returns (bool);
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);
    
    event Transfer(
        address indexed from,
        address indexed to,
        uint256 value
    );
    
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

// SPDX-License-Identifier: none

pragma solidity ^0.8.0;

interface ILiquidity {
    //usage to checking liquidity is have token0 and token1 (Fork uniswap like Pancake, Biswap, etc with similar function)

    function token0() external view returns (address);
    function token1() external view returns (address);
}

// SPDX-License-Identifier: none

import "./IERC721.sol";

pragma solidity ^0.8.0;

interface IERC721Metadata is IERC721 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function tokenURI(uint256 tokenId) external view returns (string memory);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/introspection/ERC165Checker.sol)

pragma solidity ^0.8.0;

import "../interface/IERC165.sol";

/**
 * @dev Library used to query support of an interface declared via {IERC165}.
 *
 * Note that these functions return the actual result of the query: they do not
 * `revert` if an interface is not supported. It is up to the caller to decide
 * what to do in these cases.
 */
library ERC165Checker {
    // As per the EIP-165 spec, no interface should ever match 0xffffffff
    bytes4 private constant _INTERFACE_ID_INVALID = 0xffffffff;

    /**
     * @dev Returns true if `account` supports the {IERC165} interface,
     */
    function supportsERC165(address account) internal view returns (bool) {
        // Any contract that implements ERC165 must explicitly indicate support of
        // InterfaceId_ERC165 and explicitly indicate non-support of InterfaceId_Invalid
        return
            supportsERC165InterfaceUnchecked(account, type(IERC165).interfaceId) &&
            !supportsERC165InterfaceUnchecked(account, _INTERFACE_ID_INVALID);
    }

    /**
     * @dev Returns true if `account` supports the interface defined by
     * `interfaceId`. Support for {IERC165} itself is queried automatically.
     *
     * See {IERC165-supportsInterface}.
     */
    function supportsInterface(address account, bytes4 interfaceId) internal view returns (bool) {
        // query support of both ERC165 as per the spec and support of _interfaceId
        return supportsERC165(account) && supportsERC165InterfaceUnchecked(account, interfaceId);
    }

    /**
     * @dev Returns a boolean array where each value corresponds to the
     * interfaces passed in and whether they're supported or not. This allows
     * you to batch check interfaces for a contract where your expectation
     * is that some interfaces may not be supported.
     *
     * See {IERC165-supportsInterface}.
     *
     * _Available since v3.4._
     */
    function getSupportedInterfaces(address account, bytes4[] memory interfaceIds)
        internal
        view
        returns (bool[] memory)
    {
        // an array of booleans corresponding to interfaceIds and whether they're supported or not
        bool[] memory interfaceIdsSupported = new bool[](interfaceIds.length);

        // query support of ERC165 itself
        if (supportsERC165(account)) {
            // query support of each interface in interfaceIds
            for (uint256 i = 0; i < interfaceIds.length; i++) {
                interfaceIdsSupported[i] = supportsERC165InterfaceUnchecked(account, interfaceIds[i]);
            }
        }

        return interfaceIdsSupported;
    }

    /**
     * @dev Returns true if `account` supports all the interfaces defined in
     * `interfaceIds`. Support for {IERC165} itself is queried automatically.
     *
     * Batch-querying can lead to gas savings by skipping repeated checks for
     * {IERC165} support.
     *
     * See {IERC165-supportsInterface}.
     */
    function supportsAllInterfaces(address account, bytes4[] memory interfaceIds) internal view returns (bool) {
        // query support of ERC165 itself
        if (!supportsERC165(account)) {
            return false;
        }

        // query support of each interface in _interfaceIds
        for (uint256 i = 0; i < interfaceIds.length; i++) {
            if (!supportsERC165InterfaceUnchecked(account, interfaceIds[i])) {
                return false;
            }
        }

        // all interfaces supported
        return true;
    }

    /**
     * @notice Query if a contract implements an interface, does not check ERC165 support
     * @param account The address of the contract to query for support of an interface
     * @param interfaceId The interface identifier, as specified in ERC-165
     * @return true if the contract at account indicates support of the interface with
     * identifier interfaceId, false otherwise
     * @dev Assumes that account contains a contract that supports ERC165, otherwise
     * the behavior of this method is undefined. This precondition can be checked
     * with {supportsERC165}.
     * Interface identification is specified in ERC-165.
     */
    function supportsERC165InterfaceUnchecked(address account, bytes4 interfaceId) internal view returns (bool) {
        // prepare call
        bytes memory encodedParams = abi.encodeWithSelector(IERC165.supportsInterface.selector, interfaceId);

        // perform static call
        bool success;
        uint256 returnSize;
        uint256 returnValue;
        assembly {
            success := staticcall(30000, account, add(encodedParams, 0x20), mload(encodedParams), 0x00, 0x20)
            returnSize := returndatasize()
            returnValue := mload(0x00)
        }

        return success && returnSize >= 0x20 && returnValue > 0;
    }
}

// SPDX-License-Identifier: none

import "./IERC165.sol";

pragma solidity ^0.8.0;

interface IERC721 is IERC165 {
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    function balanceOf(address owner) external view returns (uint256 balance);
    function ownerOf(uint256 tokenId) external view returns (address owner);
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    function approve(address to, uint256 tokenId) external;
    function getApproved(uint256 tokenId) external view returns (address operator);
    function setApprovalForAll(address operator, bool _approved) external;
    function isApprovedForAll(address owner, address operator) external view returns (bool);
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;
}

// SPDX-License-Identifier: none

pragma solidity ^0.8.0;

interface IERC165 {
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}