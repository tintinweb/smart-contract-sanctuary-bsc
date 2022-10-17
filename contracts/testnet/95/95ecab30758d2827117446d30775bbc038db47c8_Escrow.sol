// SPDX-License-Identifier: None
pragma solidity ^0.8.0;
pragma abicoder v2;
import "./Ownable.sol";
import "./IERC20_Escrow.sol";
import "./ECDSA.sol";

contract Escrow is Ownable{
    using ECDSA for bytes32;

    event JobCreated(uint256 jobId, address contractor, address freelancer, uint256 payment, uint256 fees);
    event JobCancelled(uint256 jobId);
    event JobComplete(uint256 jobId);
    event PaymentReleased(uint256 jobId, uint256 paymentToRelease);

    struct Job{
        address freelancer;
        uint96 payment;
    }

    struct JobCreate{
        uint256 jobId;
        address freelancer;
        uint96 payment;
        uint256 fees;
        uint256 startTime;
        uint256 endTime;
    }

    struct JobInteract{
        uint256 jobId;
        uint256 fees;
        uint256 startTime;
        uint256 endTime;
    }

    address public USDT;
    address public SPAY;
    address public feesRegistry;

    bytes32 private constant JOB_CREATION_TYPEHASH =
        keccak256("jobCreation(address contractor,uint256 jobId,address freelancer,uint256 payment,uint256 fees,uint256 startTime,uint256 endTime)");

    bytes32 private constant JOB_CANCELLATION_TYPEHASH =
        keccak256("jobCancellation(uint256 jobId,uint256 fees,uint256 startTime,uint256 endTime)");

    bytes32 private constant JOB_CLAIM_TYPEHASH =    
        keccak256("jobClaim(uint256 jobId,uint256 fees,uint256 startTime,uint256 endTime)");
        

    bytes32 private DOMAIN_SEPARATOR;
    address platformSigner;


    mapping (uint256 => Job) public job;
    mapping (uint256 => bool) public cancellation;
    mapping (uint256 => bool) public completion;
    mapping (uint256 => uint256) public releasedPayment;
    mapping (uint256 => uint256) public claimedPayment;


    constructor( address _platformSigner, address _USDT, address _SPAY, address _feesRegistry){
    
        platformSigner = _platformSigner;
        USDT = _USDT;
        SPAY= _SPAY;
        feesRegistry = _feesRegistry;

        uint256 chainId;
        assembly {
        chainId := chainid()
        }

        DOMAIN_SEPARATOR = keccak256(
            abi.encode(
                keccak256(
                "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"
                ),
                //TODO CHANGE
                keccak256(bytes("ProjectName")),
                keccak256(bytes("1")),
                chainId,
                address(this)
            )
        );
    }

    // modifier checkJobCreator(uint256 jobId){
    //     address sender = address(uint160(jobId>>96));
    //     if(sender != msg.sender) revert("Caller is not owner of job Id");
    //     _;
    // }

    function initializeJob(JobCreate memory jobCreation) external { //checkJobCreator(jobCreation.jobId)
        Job memory _job = Job(jobCreation.freelancer, uint96(jobCreation.payment));
        if(job[jobCreation.jobId].freelancer != address(0)) revert("job id exists");
        require(jobCreation.startTime <= block.timestamp && jobCreation.endTime > block.timestamp, "Invalid Job Creation time");

        // bytes32 digest = keccak256(
        //     abi.encodePacked(
        //         "\x19\x01",
        //         DOMAIN_SEPARATOR,
        //         keccak256(abi.encode(JOB_CREATION_TYPEHASH, msg.sender, jobCreation.jobId, jobCreation.freelancer,
        //          jobCreation.payment, jobCreation.fees, jobCreation.startTime, jobCreation.endTime))
        //     )
        // );

        // address signer = digest.recover(signature);
        // require(signer != address(0) && signer == platformSigner, "Invalid signature");

        job[jobCreation.jobId] = _job;

        // Pay USDT
        IERC20(USDT).transferFrom(msg.sender, address(this), jobCreation.payment);

        // Pay SPay
        IERC20(SPAY).transferFrom(msg.sender, feesRegistry, jobCreation.fees);

        emit JobCreated(jobCreation.jobId, msg.sender, jobCreation.freelancer, jobCreation.payment, jobCreation.fees);
    }


    function cancelJob(JobInteract memory jobCancel) external { //checkJobCreator(jobCancel.jobId)
        if(!cancellation[jobCancel.jobId]) revert("Not cancelled by admin");
        if(completion[jobCancel.jobId]) revert("Job already complete");
        require(jobCancel.startTime <= block.timestamp && jobCancel.endTime > block.timestamp, "Invalid Job Cancellation time");

        // bytes32 digest = keccak256(
        //     abi.encodePacked(
        //         "\x19\x01",
        //         DOMAIN_SEPARATOR,
        //         keccak256(abi.encode(JOB_CANCELLATION_TYPEHASH, jobCancel.jobId, jobCancel.fees, jobCancel.startTime, jobCancel.endTime))
        //     )
        // );

        // address signer = digest.recover(signature);
        // require(signer != address(0) && signer == platformSigner,"Invalid signature");

        completion[jobCancel.jobId] = true;

        // Transfer USDT to contractor
        IERC20(USDT).transfer(msg.sender, job[jobCancel.jobId].payment - releasedPayment[jobCancel.jobId]); // remaining amount

        // Pay platform fees
        IERC20(SPAY).transferFrom(msg.sender, feesRegistry, jobCancel.fees);

        emit JobCancelled(jobCancel.jobId);
    }

    function releasePayment(uint256 jobId, uint256 paymentToRelease) external { //checkJobCreator(jobId)
        if(completion[jobId]) revert ("Job already complete");
        Job memory _job = job[jobId];
        require(releasedPayment[jobId] + paymentToRelease <= _job.payment, "Payment release exceeds job payment");
        if(releasedPayment[jobId] + paymentToRelease == _job.payment) completion[jobId] = true;
        releasedPayment[jobId] += paymentToRelease;
        emit PaymentReleased(jobId,paymentToRelease);
    }

    function claimPayment(JobInteract memory jobClaim) external {
        require(claimedPayment[jobClaim.jobId] < releasedPayment[jobClaim.jobId] , "Nothing left to claim");

        // bytes32 digest = keccak256(
        //     abi.encodePacked(
        //         "\x19\x01",
        //         DOMAIN_SEPARATOR,
        //         keccak256(abi.encode(JOB_CLAIM_TYPEHASH, jobClaim.jobId, jobClaim.fees, jobClaim.startTime, jobClaim.endTime))
        //     )
        // );

        // address signer = digest.recover(signature);
        // require(signer != address(0) && signer == platformSigner, "Invalid signature");

        Job memory _job = job[jobClaim.jobId];
        uint256 paymentToClaim = releasedPayment[jobClaim.jobId] - claimedPayment[jobClaim.jobId];
        claimedPayment[jobClaim.jobId] = releasedPayment[jobClaim.jobId];

        // Get paid
        IERC20(USDT).transfer(_job.freelancer, paymentToClaim);

        // Pay fees in SPay
        IERC20(SPAY).transferFrom(_job.freelancer, feesRegistry, jobClaim.fees);
    }

    function cancelJobAdmin(uint256 jobId) external onlyOwner{
        cancellation[jobId] = true;
    }
}