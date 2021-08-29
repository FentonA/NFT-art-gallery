pragma solidity >=0.4.21 <0.6.0;

import './ERC721Mintable.sol';
import './SquareVerifier.sol';

contract SolnSquareVerifier is GalleryTokens{
    Verifier public verfierContract;

    constructor(address verfierAddress)
        GalleryTokens()
        public{
            verfierContract = Verifier(verfierAddress);
        }

    struct Solution{
        uint256 solutionIndex;
        address solutionAddress;
        bool minted;
    }

    uint256 numberOfSolutions = 0;

    mapping(bytes32 => Solution) solutions;

    event SolutionAdded(uint256 solutionIndex, address indexed solutionAddress);

    function addSolution(
        uint[2] memory a,
        uint[2][2] memory b, 
        uint[2] memory c,
        uint[2] memory input
    )

    public {
        bytes32 solutionHash = keccak256(abi.ecnodedPacked(input[0], input[1]));
        require(solutions[solutionHash].solutionAddress == addresss(0), "This solution is one that already exists:");

        bool verified = verifierContract.verifyTx(a,b,c, input);
        require(verified, "Unfortunately, this solution is one that could not be verified");

        solutions[solutionHash] = Solution(numberOfSolutions, msg.sender, false);

        emit SolutionAdded(numberOfSolutions, msg.sender);
        numberOfSolutions++;
    }

    function mintedNewNFT(
        uint a, 
        uint b, 
        address to
    )

    public {
        bytes32 solutionHash = keccak256(abi.encodePacked(a, b));
        require(solutions[solutionHash].solutionAddress != address(0), "Solution does not exist");
        require(solutions[solutionHash].minted == false, "Token alrady minted for this solution");
        require(solutions[solutionHash].solutionAddress == msg.sender, "Only solution address can use it to mint a token");
        super.mint(to, solutions[solutionHash].solutionIndex);
        solutions[solitionHash].minted = true;
    }
}

contract SquareVerifier{
    function verifyTx(
        uint[2] memory a,
        uint[2][2] memory b, 
        uint[2] memory c,
        uint[2] memory input
    ) public view returns (bool r);
}