

main.o: main.cpp
	@echo $(CXX) $(CXXFLAGS) $(CPPFLAGS) -c -o $@ $^
	$(CXX) $(CXXFLAGS) $(CPPFLAGS) -c -o $@ $^

%.o: %.c
	@echo $(CC) $(CFLAGS) $(CPPFLAGS) -c $< -o $@
	$(CC) $(CFLAGS) $(CPPFLAGS) -c $< -o $@
	