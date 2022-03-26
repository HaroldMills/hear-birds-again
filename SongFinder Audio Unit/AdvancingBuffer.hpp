//
//  AdvancingBuffer.hpp
//  HearBirdsAgain
//
//  Created by Harold Mills on 3/25/22.
//


#ifndef ADVANCING_BUFFER
#define ADVANCING_BUFFER


#include <cstring>


using std::size_t;


template <class T>
class AdvancingBuffer {


public:


    AdvancingBuffer(size_t capacity) {

        _capacity = capacity;

        _elements = new T[_capacity];

        _buffer_start_index = 0;
        _data_start_offset = 0;
        _data_end_offset = 0;

    }


    size_t capacity() {
        return _capacity;
    }


    size_t size() {
        return _data_end_offset - _data_start_offset;
    }


    size_t start_index() {
        return _buffer_start_index + _data_start_offset;
    }


    size_t end_index() {
        return _buffer_start_index + _data_end_offset;
    }


    T *data() {
        return _elements + _data_start_offset;
    }


    T *extend(size_t element_count) {

        if (this->size() + element_count > _capacity)
            throw "AdvancingBuffer overflow";

        // Move data to beginning of buffer if needed to make room
        // for extension.
        if (_data_end_offset + element_count > _capacity) {

            const size_t offset = _data_start_offset * sizeof(T);
            const void *src = ((char *) _elements) + offset;
            void *dest = _elements;
            const size_t size = this->size() * sizeof(T);
            std::memmove(dest, src, size);

            _buffer_start_index += _data_start_offset;
            _data_end_offset -= _data_start_offset;
            _data_start_offset = 0;

        }

        // Get pointer to start of extension.
        T *result = _elements + _data_end_offset;

        // Update data end offset.
        _data_end_offset += element_count;

        return result;

    }


    void append(const T *values, size_t value_count) {

        // Extend buffer.
        void *dest = extend(value_count);

        // Copy values to extension.
        size_t size = value_count * sizeof(T);
        std::memcpy(dest, values, size);

    }


    void append_zeros(size_t zero_count) {

        // Extend buffer.
        T *dest = extend(zero_count);

        // Set elements to zero.
        for (size_t i = 0; i != zero_count; ++i)
            dest[i] = 0;

    }


    void discard(size_t element_count) {

        if (element_count > size())
            throw "AdvancingBuffer underflow";

        _data_start_offset += element_count;

    }


private:
    size_t _capacity;
    T *_elements;
    size_t _buffer_start_index;
    size_t _data_start_offset;
    size_t _data_end_offset;


};


#endif
