#ifndef KMP_H
#define KMP_H

#include <vector>
#include <string>

/**
 * Computes the Longest Proper Prefix which is also a Suffix (LPS) array.
 */
inline void computeLPSArray(const std::string& pattern, std::vector<int>& lps){
    int length = 0;
    lps[0] = 0;
    int i = 1;
    while(i < pattern.length()){
        if(pattern[i] == pattern[length]){
            lps[i++] = ++length;
        } else {
            if(length != 0){
                length = lps[length - 1];
            } else {
                lps[i++] = 0;
            }
        }
    }
}

/**
 * Knuth-Morris-Pratt string matching algorithm.
 * Returns a vector of 0s and 1s where 1 indicates a match start.
 */
inline std::vector<int> KMPSearch(const std::string& text, const std::string& pattern){
    int M = pattern.length();
    int N = text.length();
    std::vector<int> result(N, 0);
    if(M == 0) return result;
    std::vector<int> lps(M);
    computeLPSArray(pattern, lps);
    int i = 0, j = 0;
    while(i < N){
        if(pattern[j] == text[i]){
            j++;
            i++;
        }
        if(j == M){
            result[i - j] = 1;
            j = lps[j - 1];
        } else if(i < N && pattern[j] != text[i]){
            if(j != 0){
                j = lps[j - 1];
            } else {
                i++;
            }
        }
    }
    return result;
}

#endif
