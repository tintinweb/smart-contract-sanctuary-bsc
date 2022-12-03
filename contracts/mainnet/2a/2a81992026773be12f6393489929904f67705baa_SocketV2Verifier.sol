/**
 *Submitted for verification at BscScan.com on 2022-12-03
*/

// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.4;


interface ISocketRegistry {
    /// @param id route id of middleware to be used
    /// @param optionalNativeAmount is the amount of native asset that the route requires
    /// @param inputToken token address which will be swapped to BridgeRequest inputToken
    /// @param data to be used by middleware
    struct MiddlewareRequest {
        uint256 id;
        uint256 optionalNativeAmount;
        address inputToken;
        bytes data;
    }

    /// @param id route id of bridge to be used
    /// @param optionalNativeAmount optinal native amount, to be used when bridge needs native token along with ERC20
    /// @param inputToken token addresss which will be bridged
    /// @param data bridgeData to be used by bridge
    struct BridgeRequest {
        uint256 id;
        uint256 optionalNativeAmount;
        address inputToken;
        bytes data;
    }

    /// @param receiverAddress Recipient address to recieve funds on destination chain
    /// @param toChainId Destination ChainId
    /// @param amount amount to be swapped if middlewareId is 0  it will be
    /// the amount to be bridged
    /// @param middlewareRequest middleware Requestdata
    /// @param bridgeRequest bridge request data
    struct UserRequest {
        address receiverAddress;
        uint256 toChainId;
        uint256 amount;
        MiddlewareRequest middlewareRequest;
        BridgeRequest bridgeRequest;
    }

    /// @notice RouteData stores information for a route
    struct RouteData {
        address route;
        bool isEnabled;
        bool isMiddleware;
    }

    function routes() external view returns (RouteData[] memory);

    function outboundTransferTo(UserRequest calldata _userRequest) external payable;
}


library CallDataVerifyErrors {
    string internal constant INVALID_TARGET = "INVALID_TARGET";
    string internal constant INVALID_TO_CHAIN_ID = "INVALID_TO_CHAIN_ID";
    string internal constant INVALID_RECEIVER_ADDRESS = "INVALID_RECEIVER_ADDRESS";
    string internal constant INVALID_AMOUNT = "INVALID_AMOUNT";

    string internal constant INVALID_BRIDGE_ID = "INVALID_BRIDGE_ID";
    string internal constant INVALID_BRIDGE_AMOUNT = "INVALID_BRIDGE_AMOUNT";
    string internal constant INVALID_BRIDGE_TOKEN = "INVALID_BRIDGE_TOKEN";

    string internal constant INVALID_MIDDLEWARE_ID = "INVALID_MIDDLEWARE_ID";
    string internal constant INVALID_MIDDLEWARE_AMOUNT = "INVALID_MIDDLEWARE_AMOUNT";
    string internal constant INVALID_MIDDLEWARE_TOKEN = "INVALID_MIDDLEWARE_TOKEN";
}

library ApprovalVerifyErrors {
    string internal constant INVALID_TARGET = "INVALID_TARGET";
    string internal constant INVALID_ROUTE = "INVALID_ROUTE";
    string internal constant INVALID_SPENDER = "INVALID_SPENDER";
    string internal constant INVALID_AMOUNT = "INVALID_AMOUNT";
}



contract SocketV2Verifier {
    /// @param id route id of middleware to be used
    /// @param optionalNativeAmount is the amount of native asset that the route requires
    /// @param inputToken token address which will be swapped to BridgeRequest inputToken
    /// @param data to be used by middleware
    struct MinMiddlewareRequest {
        uint256 id;
        uint256 optionalNativeAmount;
        address inputToken;
    }

    /// @param id route id of bridge to be used
    /// @param optionalNativeAmount optinal native amount, to be used when bridge needs native token along with ERC20
    /// @param inputToken token addresss which will be bridged
    struct MinBridgeRequest {
        uint256 id;
        uint256 optionalNativeAmount;
        address inputToken;
    }

    /// @notice The expected parameters
    /// @param target The target expected - should be socket registry
    /// @param receiverAddress Recipient address to recieve funds on destination chain
    /// @param toChainId Destination ChainId
    /// @param amount amount to be swapped if middlewareId is 0  it will be
    /// the amount to be bridged
    /// @param middlewareRequest middleware Requestdata
    /// @param bridgeRequest bridge request data
    struct ExpectedRequest {
        address target;
        address receiverAddress;
        uint256 toChainId;
        uint256 amount;
        MinMiddlewareRequest middlewareRequest;
        MinBridgeRequest bridgeRequest;
    }

    /// @notice The expected approval parameters
    /// @param target The target expected - should be the tocket being approved
    /// @param routeId The expected route id
    /// @param amount The expected amount
    struct ExpectedApproval {
        address target;
        uint256 routeId;
        uint256 amount;
    }

    /// @notice Verify the calldata to V2 with a given expected request
    /// @param target The address where the call data will be sent
    /// @param data Socket V2 call data
    /// @param expected User equest that is expected
    function verifyCallData(
        address target,
        bytes calldata data,
        ExpectedRequest calldata expected
    ) public view {
        require(target == expected.target, CallDataVerifyErrors.INVALID_TARGET);
        ISocketRegistry.UserRequest memory userRequest = decodeCallData(data);
        require(userRequest.toChainId == expected.toChainId, CallDataVerifyErrors.INVALID_TO_CHAIN_ID);
        require(userRequest.receiverAddress == expected.receiverAddress, CallDataVerifyErrors.INVALID_RECEIVER_ADDRESS);
        require(userRequest.amount == expected.amount, CallDataVerifyErrors.INVALID_AMOUNT);
        this.verifyBridgeRequest(userRequest.bridgeRequest, expected.bridgeRequest);
        this.verifyMiddlewareRequest(userRequest.middlewareRequest, expected.middlewareRequest);
    }

    /// @notice Verify the approval call data
    /// @param target The address where the approval will be sent. This should be the input token.
    /// @param data Approval call data
    /// @param registryAddress The address of the socket registry
    /// @param expected Approval parameters that are expected
    function verifyApprovalData(
        address target,
        bytes calldata data,
        address registryAddress,
        ExpectedApproval calldata expected
    ) public view {
        require(target == expected.target, ApprovalVerifyErrors.INVALID_TARGET);
        (address spender, uint256 amount) = decodeApprovalData(data);
        ISocketRegistry.RouteData memory expectedRoute = ISocketRegistry(registryAddress).routes()[expected.routeId];
        require(expectedRoute.isEnabled, ApprovalVerifyErrors.INVALID_ROUTE);
        require(spender == expectedRoute.route, ApprovalVerifyErrors.INVALID_SPENDER);
        require(amount == expected.amount, ApprovalVerifyErrors.INVALID_AMOUNT);
    }

    /// @notice Verify the bridge request
    /// @param request Bridge request
    /// @param expected Bridge request that is expected
    function verifyBridgeRequest(ISocketRegistry.BridgeRequest calldata request, MinBridgeRequest calldata expected)
        public
        pure
    {
        require(request.id == expected.id, CallDataVerifyErrors.INVALID_BRIDGE_ID);
        require(
            request.optionalNativeAmount == expected.optionalNativeAmount,
            CallDataVerifyErrors.INVALID_BRIDGE_AMOUNT
        );
        require(request.inputToken == expected.inputToken, CallDataVerifyErrors.INVALID_BRIDGE_TOKEN);
    }

    /// @notice Verify the middleware request if it is specified
    /// @param request Middleware request
    /// @param expected Middleware request that is expected
    function verifyMiddlewareRequest(
        ISocketRegistry.MiddlewareRequest calldata request,
        MinMiddlewareRequest calldata expected
    ) public pure {
        if (request.id == 0) {
            // If middleware request ID is 0, middleware verification is not required
            return;
        }
        require(request.id == expected.id, CallDataVerifyErrors.INVALID_MIDDLEWARE_ID);
        require(
            request.optionalNativeAmount == expected.optionalNativeAmount,
            CallDataVerifyErrors.INVALID_MIDDLEWARE_AMOUNT
        );
        require(request.inputToken == expected.inputToken, CallDataVerifyErrors.INVALID_MIDDLEWARE_TOKEN);
    }

    /// @notice Decode the socket v2 calldata
    /// @param data Socket V2 outboundTransferTo call data
    /// @return userRequest socket UserRequest
    function decodeCallData(bytes calldata data)
        internal
        pure
        returns (ISocketRegistry.UserRequest memory userRequest)
    {
        (userRequest) = abi.decode(data[4:], (ISocketRegistry.UserRequest));
    }

    /// @notice Decode erc20 approval call
    /// @param data ERC20 apporval calldata
    /// @return spender erc20 spender
    /// @return amount erc20 amount
    function decodeApprovalData(bytes calldata data) internal pure returns (address spender, uint256 amount) {
        (spender, amount) = abi.decode(data[4:], (address, uint256));
    }
}

interface IERC20 {
    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);
}